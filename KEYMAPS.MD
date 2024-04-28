# Tmux + Nvim keymaps that I learn as I go.


### NOTE: These are custom keymaps for Nvim and Tmux.
-------------------------------------------------
Prefix = ^a

#### buffer management
space + tl = next buffer
space + th = previous buffer
space + td = delete buffer
space + QQ = close buffer


#### tmux management (sessions/windows/panes)
^a + ^C = new tmux window
^a + 1-9 = select tmux window
^a + s = split tmux pane
^a + v = vsplit tmux pane
^a + c = close tmux pane
^a + S = open tmux sessions
^a + r = rename window
^a + d = detach tmux
^a + $ = rename session


#### nvim commands
space + ng = neogit
space + B = line beginning
space + E = line end
space + WW = write file
space + qq = quit file, save buffer
space + st = telescope :notes
space + tw = twilight mode on/off

shift + ( = quick up
shift + ) = quick down

shift + v = select text
> finish with c = cut selected text
> finish with d = delete selected text
> finish with y = yank selected text
> finish with p = paste selected text



