config.set('url.searchengines', {'DEFAULT': 'google.com/search?q={}'})
#config.set('colors.webpage.darkmode.enabled', True)
config.set('colors.webpage.preferred_color_scheme', 'dark')
config.load_autoconfig(False)
c.url.start_pages = ['about:blank']
c.content.default_encoding = 'utf-8' # (This might already be there)
# --- Add this line ---
config.set('session.lazy_restore', True)

# Tell qutebrowser to use an external program for file selection
c.fileselect.handler = "external"

# Define the command for selecting a single file
c.fileselect.single_file.command = ['ghostty', '-e', 'yazi', '--chooser-file={}']

# Define the command for selecting multiple files
c.fileselect.multiple_files.command = ['ghostty', '-e', 'yazi', '--chooser-file={}']

# Define the command for selecting a folder
# Note: Yazi handles folder selection with the same command
c.fileselect.folder.command = ['ghostty', '-e', 'yazi', '--chooser-file={}']
