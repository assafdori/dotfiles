# Tmux and Nvim keymaps that I document as I go.


### NOTE: These are custom keymaps for Nvim and Tmux for my setup
-------------------------------------------------

``` Prefix = ^a ```

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
^a + I = install tpm plugins
^a + [ = enter copy mode

#### nvim commands
space + ng = neogit  
space + B = line beginning  
space + E = line end  
space + WW = write file  
space + qq = quit file, save buffer  
space + st = telescope search :notes  
space + sf = telescope search files
space + tw = twilight mode on/off
none  + / = fuzzily search current buffer
space + tt = toggle fterm

shift + ( = quick up  
shift + ) = quick down  
 
shift + v = select text 
 - finish with c = cut selected text  
 - finish with d = delete selected text  
 - finish with y = yank selected text  
 - finish with p = paste selected text  

random cool stuff =
space + tt & cmd btop = terminal with btop
space + tt & cmd htop = terminal with htop
z= = toggle auto-correction menu
1z= = select first auto correction suggestion


#### NOTE: for writing notes inside code blocks and be able to telescope search them
#### BUG: for writing bugs inside code blocks and be able to telescope search them
#### TODO: for writing todos inside code blocks and be able to telescope search them
