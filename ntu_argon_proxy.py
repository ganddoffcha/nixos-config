#!/usr/bin/env python3
import hashlib, json, os, re, sys, time, uuid, urllib.request, urllib.error
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn

CURL_FILE = os.path.expanduser("~/curl.txt")
STATE = {"mtime": 0, "url": "", "headers": {}, "payload": {}, "cookies": {}}

def parse_cookie_str(cookie_str):
    cookies = {}
    for pair in cookie_str.split(";"):
        if "=" in pair:
            k, v = pair.strip().split("=", 1)
            cookies[k.strip()] = v.strip()
    return cookies

def format_cookie_str(cookies):
    return "; ".join(f"{k}={v}" for k, v in cookies.items())

def reload_if_needed(force=False):
    if not os.path.exists(CURL_FILE):
        print(f"❌ {CURL_FILE} not found! Copy widgetStreamAssist as cURL and run: argon -u")
        return False
    mtime = os.path.getmtime(CURL_FILE)
    if not force and mtime <= STATE["mtime"]:
        return True

    with open(CURL_FILE, "r", encoding="utf-8") as f:
        raw = f.read()

    url_match = re.search(r"'(https://[^']+)'|\"(https://[^\"]+)\"|(https://\S+)", raw)
    if not url_match:
        print("❌ Could not find https:// URL in ~/curl.txt!")
        return False
    url = next(g for g in url_match.groups() if g)

    headers = {}
    for m in re.finditer(r"(?:-H|--header)\s+\$?'([^']*)'|(?:-H|--header)\s+\"([^\"]*)\"", raw):
        h = m.group(1) if m.group(1) is not None else m.group(2)
        if ":" in h:
            k, v = h.split(":", 1)
            if k.strip().lower() not in ("content-length", "accept-encoding"):
                headers[k.strip()] = v.strip()

    b_match = re.search(r"(?:-b|--cookie)\s+\$?'([^']*)'|(?:-b|--cookie)\s+\"([^\"]*)\"", raw)
    if b_match:
        headers["cookie"] = b_match.group(1) if b_match.group(1) is not None else b_match.group(2)

    cookie_str = headers.get("cookie") or headers.get("Cookie") or ""
    cookies = parse_cookie_str(cookie_str)

    idx, ridx = raw.find('{"configId"'), raw.rfind('}')
    if idx == -1 or ridx == -1:
        print("❌ Could not find JSON payload in ~/curl.txt!")
        return False
    base_payload = json.loads(raw[idx:ridx+1])

    STATE.update({"mtime": mtime, "url": url, "headers": headers, "payload": base_payload, "cookies": cookies})
    print(f"🔄 Loaded ~/curl.txt ({len(headers)} headers, {len(cookies)} cookies)")
    return True

def build_fresh_headers():
    headers = dict(STATE["headers"])
    cookies = STATE["cookies"]
    origin = headers.get("origin") or headers.get("Origin") or "https://vertexaisearch.cloud.google.com"
    ts = int(time.time())
    auth_parts = []
    for scheme, cname in (("SAPISIDHASH", "SAPISID"), ("SAPISID1PHASH", "__Secure-1PAPISID"), ("SAPISID3PHASH", "__Secure-3PAPISID")):
        val = cookies.get(cname) or cookies.get("SAPISID")
        if val:
            h = hashlib.sha1(f"{ts} {val} {origin}".encode("utf-8")).hexdigest()
            auth_parts.append(f"{scheme} {ts}_{h}")
    if auth_parts:
        for k in list(headers.keys()):
            if k.lower() == "authorization":
                headers[k] = " ".join(auth_parts)
                break
        else:
            headers["authorization"] = " ".join(auth_parts)
    headers["cookie"] = format_cookie_str(cookies)
    return headers

def extract_text_recursive(obj, out_list):
    if isinstance(obj, dict):
        if "text" in obj and isinstance(obj["text"], str):
            if not obj.get("thought", False):
                out_list.append(obj["text"])
        else:
            for k, v in obj.items():
                if k != "query":
                    extract_text_recursive(v, out_list)
    elif isinstance(obj, list):
        for item in obj:
            extract_text_recursive(item, out_list)

def ask_ntu_argon(prompt_text: str) -> str:
    reload_if_needed()
    payload = json.loads(json.dumps(STATE["payload"]))
    req_body = payload["streamAssistRequest"]
    req_body["query"] = {"parts": [{"text": prompt_text}]}
    req_body["fileIds"] = []
    req_body["assistGenerationConfig"] = {"modelId": "gemini-4-argon"}
    req_body["toolsSpec"] = {}

    data = json.dumps(payload).encode("utf-8")
    headers = build_fresh_headers()
    req = urllib.request.Request(STATE["url"], data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            for k, v in resp.headers.items():
                if k.lower() == "set-cookie":
                    c_pair = v.split(";", 1)[0]
                    if "=" in c_pair:
                        ck, cv = c_pair.split("=", 1)
                        STATE["cookies"][ck.strip()] = cv.strip()
            raw_resp = resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="ignore")
        print(f"❌ HTTP Error {e.code}: {err_body[:300]}")
        return f"[HTTP Error {e.code} - Run 'argon -u' after copying fresh cURL from Brave DevTools]: {err_body[:200]}"

    try:
        parsed = json.loads(raw_resp)
    except Exception:
        return raw_resp[:1000]

    out = []
    if isinstance(parsed, list):
        for chunk in parsed:
            for reply in chunk.get("answer", {}).get("replies", []):
                parts = reply.get("groundedContent", {}).get("content", {}).get("parts", [])
                for p in parts:
                    if "text" in p and not p.get("thought", False):
                        out.append(p["text"])
    if not out:
        extract_text_recursive(parsed, out)
    return "".join(out) or "[Empty reply]"

def build_prompt_with_tools(messages, tools):
    parts = []
    if tools:
        tool_schemas = json.dumps(tools, indent=2)
        parts.append(
            "SYSTEM INSTRUCTION FOR TOOL CALLING:\n"
            "You are connected to an IDE agent that requires tool calls to act.\n"
            "Whenever you want to invoke a tool from the AVAILABLE TOOLS below, output a tool call block in this EXACT format:\n"
            "<tool_call>\n"
            "{\"name\": \"TOOL_NAME\", \"arguments\": {\"arg1\": \"val1\"}}\n"
            "</tool_call>\n"
            "Always use at least one <tool_call> block when performing actions or completing a task!\n\n"
            f"AVAILABLE TOOLS:\n{tool_schemas}\n"
        )
    for m in messages:
        role = m.get("role", "user").upper()
        content = m.get("content", "")
        if isinstance(content, list):
            text_pieces = []
            for c in content:
                if isinstance(c, dict):
                    if c.get("type") == "text":
                        text_pieces.append(c.get("text", ""))
                    elif c.get("type") == "tool_result":
                        text_pieces.append(f"[Tool Result]: {json.dumps(c)}")
            content = "\n".join(text_pieces)
        if m.get("tool_calls"):
            content = (content or "") + "\n" + json.dumps(m["tool_calls"])
        parts.append(f"[{role}]\n{content}")
    return "\n\n".join(parts)

def parse_tool_calls(answer_text: str):
    tool_calls = []
    spans_to_remove = []
    decoder = json.JSONDecoder()
    open_tag = "<" + "tool_call>"
    close_tag = "</" + "tool_call>"
    pos = 0
    while True:
        start_tag = answer_text.find(open_tag, pos)
        if start_tag == -1:
            break
        brace_pos = answer_text.find("{", start_tag + len(open_tag))
        if brace_pos == -1:
            break
        try:
            call_obj, end_json = decoder.raw_decode(answer_text, brace_pos)
            end_tag = answer_text.find(close_tag, end_json)
            end_span = (end_tag + len(close_tag)) if end_tag != -1 else end_json
            spans_to_remove.append((start_tag, end_span))
            name = call_obj.get("name") if isinstance(call_obj, dict) else None
            args = call_obj.get("arguments", {}) if isinstance(call_obj, dict) else {}
            if not isinstance(args, str):
                args = json.dumps(args)
            if name:
                tool_calls.append({
                    "id": f"call_{uuid.uuid4().hex[:12]}",
                    "type": "function",
                    "function": {"name": name, "arguments": args}
                })
            pos = end_span
        except Exception as e:
            print(f"Warning: Failed to raw_decode at {brace_pos}: {e}")
            pos = brace_pos + 1
    if spans_to_remove:
        pieces = []
        last = 0
        for st, en in spans_to_remove:
            pieces.append(answer_text[last:st])
            last = en
        pieces.append(answer_text[last:])
        cleaned_text = "".join(pieces).strip()
    else:
        cleaned_text = answer_text.strip()
    return cleaned_text, tool_calls

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    daemon_threads = True

class OpenAIProxy(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({
            "object": "list",
            "data": [{"id": "gemini-4-argon", "object": "model"}]
        }).encode("utf-8"))

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length))
        messages = body.get("messages", [])
        tools = body.get("tools", [])
        stream = body.get("stream", False)

        if len(messages) > 12:
            messages = [messages[0]] + messages[-10:]

        full_prompt = build_prompt_with_tools(messages, tools)
        print(f"📨 Sending prompt ({len(full_prompt)} chars, {len(tools)} tools) to NTU gemini-4-argon...")
        raw_answer = ask_ntu_argon(full_prompt)
        cleaned_text, tool_calls = parse_tool_calls(raw_answer)
        print(f"✅ Reply: {len(cleaned_text)} chars text, {len(tool_calls)} tool_calls!")

        finish_reason = "tool_calls" if tool_calls else "stop"

        try:
            if stream:
                self.send_response(200)
                self.send_header("Content-Type", "text/event-stream")
                self.send_header("Cache-Control", "no-cache")
                self.end_headers()
                delta = {"role": "assistant"}
                if cleaned_text:
                    delta["content"] = cleaned_text
                if tool_calls:
                    delta["tool_calls"] = [
                        {"index": idx, "id": tc["id"], "type": "function", "function": tc["function"]}
                        for idx, tc in enumerate(tool_calls)
                    ]
                chunk1 = {"id": f"chatcmpl-{int(time.time())}", "object": "chat.completion.chunk", "created": int(time.time()), "model": "gemini-4-argon", "choices": [{"index": 0, "delta": delta, "finish_reason": None}]}
                chunk2 = {"id": f"chatcmpl-{int(time.time())}", "object": "chat.completion.chunk", "created": int(time.time()), "model": "gemini-4-argon", "choices": [{"index": 0, "delta": {}, "finish_reason": finish_reason}]}
                self.wfile.write(f"data: {json.dumps(chunk1)}\n\ndata: {json.dumps(chunk2)}\n\ndata: [DONE]\n\n".encode("utf-8"))
            else:
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                msg = {"role": "assistant", "content": cleaned_text or None}
                if tool_calls:
                    msg["tool_calls"] = tool_calls
                self.wfile.write(json.dumps({
                    "id": f"chatcmpl-{int(time.time())}",
                    "object": "chat.completion",
                    "created": int(time.time()),
                    "model": "gemini-4-argon",
                    "choices": [{"index": 0, "message": msg, "finish_reason": finish_reason}],
                    "usage": {"prompt_tokens": 100, "completion_tokens": 100, "total_tokens": 200}
                }).encode("utf-8"))
        except (BrokenPipeError, ConnectionResetError):
            print("⚠️ Client disconnected before response was fully written.")

if __name__ == "__main__":
    reload_if_needed(force=True)
    print("🚀 NTU Gemini-4-Argon Proxy listening on http://127.0.0.1:8000/v1")
    ThreadedHTTPServer(("127.0.0.1", 8000), OpenAIProxy).serve_forever()
