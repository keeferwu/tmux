#### 在Ubuntu下安装tmux

	cd ~
	git clone https://gitee.com/keeferwu/tmux.git .tmux
	cd ~/.tmux
	./install.sh

#### tmux的优点

* 可以在单个原始会话中，分割成多个tmux 会话，同时运行多个命令行程序。
* 原始会话退出后，tmux 会话会在后台保持， 可以让新的原始会话 "接入"已经存在的tmux 会话。
* 允许每个tmux会话有多个连接窗口，因此可以多人实时共享会话 --- 结对编程 。
* 每个tmux会话还支持窗口任意的垂直和水平拆分。


#### 常用操作指令及快捷键
tmux默认的前缀操作（prefix）是 ctrl + b，用户可以根据自己的习惯更改为其他按键。
所有的快捷键都是按完prefix松开，再去按下一个功能键
在 tmux 窗口中，先按下prefix，再按下?，就会显示帮助信息。

##### 会话操作

* 列出已创建的会话

        tmux ls  --- 显示所有session
        
* 创建新会话

        tmux   --- 开启新session
        tmux new -s  <session-name>  --- 开启新session并命名
           
* 重新进入会话
    
        tmux attach -t <session-name>   --- 使用session名称接入

* 切换会话

        tmux switch -t <session-name>   --- 使用session名称切换
        快捷键：prefix s
        
* 退出会话
    
        tmux detach  --- 分离会话，进程仍然在后台运行
        快捷键：prefix d

* 关闭会话

        tmux kill-session -t <session-name>  --- 使用session名称kill
        tmux kill-session -a  --- 只保留一个终端，其他全部 kill
        
* 重命名会话

        tmux rename-session -t <new-name>  --- 重命名当前会话
        快捷键：prefix $

##### 窗口与窗格

* 新建窗口

        prefix c  --- 创建新窗口
        
* 切换窗口

        prefix w --- 列出所有窗口，可以预览并选择切换
        prefix p --- 上一个窗口  --- Shift+方向左键
        prefix n --- 下一个窗口  --- Shift+方向右键
        
* 关闭窗口

        prefix & --- 关闭当前窗口，会提示，按下y并回车确定
        
* 分割窗格

        prefix % --- 将当前窗口垂直分割窗格
        prefix " --- 将当前窗口水平分割窗格
        prefix ！--- 将当前窗格独立成一个窗口
        
* 切换窗格

        prefix 方向键 --- 光标切换窗格 --- Alt+方向键
        
* 关闭窗格

        prefix x --- 关闭当前窗格，会提示，按下y并回车确定

*  切换copy模式

        prefix [ --- 切换 copy 模式
        
##### ctrl+d   或  exit 

* 当会话 中仅有一个窗口且没有划分窗格，关闭当前会话（非退出）
* 当会话 中有两个以上的窗口且当前窗口且没有划分窗格，关闭当前窗口
* 当会话 中当前窗口中划分有多个窗格，关闭当前窗格


#### 结对编程

两个人需要对同一段代码进行编程。那么这个时候两个人可以同时登陆到服务器，使用tmux来进行编程，这样对方在文件中进行的任何操作，自己都能实时看见。

##### 使用共享帐户进行结对编程

* A 用户使用一个账号创建新的session
    
        tmux new -s  a-session
        
* B 用户使用同一个账号attach到 A用户创建的session
    
        tmux attach -t a-session
        当两人同时关联到相同的会话时，他们会看到相同的内容，并且是和相同的窗口交互。

* B 用户使用同一个账号创建新的 session 并 attach到 A用户创建的session
 
        tmux new -s b-session -t a-session
        A,B用户都在与 a-session 会话交互，但是每个用户自己新创建的窗口，对端不能操作。


##### 使用独立帐户和 Socket 进行结对编程
当多个用户使用不同帐号登录操作系统时，就存在访问 Socket 文件的权限问题了。
Tmux 的 Socket 文件默认为 `/tmp/` 或 `${TMUX_TMPDIR}/` 目录下的 default 文件。 当使用 `-L socket-name` 指定 socket name 时，该 Socket 文件为 `/tmp/` 或 `${TMUX_TMPDIR}/` 目录下的 `${socket-name}` 文件。甚至，我们可以通过 `-S socket-path` 的方法来直接指定 Socket 文件的路径。

为了让多个用户在不同帐号间共享 Tmux Session，我们可以这么做：

* 用户A用一个账号登录，指定一个 Socket 文件来创建 Session

        tmux -S /tmp/tmuxShared new -s a-session
 
    这时在  /tmp/ 目录下多了一个 shared 文件。
    
* 修改shared文件权限，让 Socket 文件让 Other 组也能访问。

        sudo chmod 777 /tmp/tmuxShared

* 用户B用不同于A的账号登录，然后用 -S 开关来关联这个 socket 的会话    
   
        tmux -S /tmp/tmuxShared a -t a-session

这样， a 和 b 就关联到了同一个会话，并且可以看到相同的内容。
这种方式中，会话加载时使用的是创建该会话的帐户下的 .tmux.conf 文件。

##### 使用tmate在不同主机端进行结对编程
tmate即teammates，是tmux的一个分支，并且和tmux使用相同的配置信息(i.e. tmate可与tmux共享~/.tmux.conf)。tmate不仅是一个终端多路复用器，而且具有即时分享终端的能力。它允许在单个屏幕中创建并操控多个终端，同时这些终端还能与其他人分享。总的来说，tmux支持的窗口(window)和窗格(pane)功能，tmate都支持。tmate的基本工作原理如下：

    * 运行tmate时，会在后台创建一个连接到tmate.io(由 tmate 开发者维护的后台服务器)的ssh连接；
    * tmate.io服务器的ssh密钥通过DH交换进行校验；
    * 客户端通过本地ssh密钥进行认证；
    * 连接创建后，本地tmux服务器会生成一个150位(不可猜测的随机字符)会话令牌；
    * 队友能通过用户提供的SSH会话ID连接到tmate.io。

* 用户A为了能使用TMATE共享，本地的ssh必须生成钥匙对(若还没有生成的话)

        ssh-keygen -t rsa

* 用户A使用tmate启动tmux窗口并查看共享的链接

        tmate
        tmate show-messages
            Sat Feb 29 20:32:31 2020 [tmate] Connecting to master.tmate.io...
            Sat Feb 29 20:32:37 2020 [tmate] Note: clear your terminal before sharing readonly access
            Sat Feb 29 20:32:37 2020 [tmate] web session read only: https://tmate.io/t/ro-59nhrEMMpr8fvYEfW3LbU69r9
            Sat Feb 29 20:32:37 2020 [tmate] ssh session read only: ssh ro-59nhrEMMpr8fvYEfW3LbU69r9@nyc1.tmate.io
            Sat Feb 29 20:32:37 2020 [tmate] web session: https://tmate.io/t/2VFPtcBNnhaNRGWmKgKZH3zfn
            Sat Feb 29 20:32:37 2020 [tmate] ssh session: ssh 2VFPtcBNnhaNRGWmKgKZH3zfn@nyc1.tmate.io

        分别是两条只读链接加两条读写链接，支持WEB和SSH两种方式。
        
* 用户B在自己的终端通过ssh进行连接
    
        ssh 2VFPtcBNnhaNRGWmKgKZH3zfn@nyc1.tmate.io
        
    然后B和A就共享了同一个Terminal。无论是A还是B都可以操作该Terminal。

* 关闭连接

        用户A在自己的终端(Terminal)上键入exit即可。

通常情况下，鉴于tmate生成的共享链接(ssh or web)在提供给他人访问的时候无需任何安全验证，而且此连接存储在tmate.io的服务器上，所以在使用此功能的时候请保持谨慎。

* 第一，只把共享链接发送给你所信任的人知晓

* 第二，如无必要，请仅仅发送只读链接

* 第三，一旦共享结束，请及时关闭会话

#### 参考

[tmux 使用手册](https://louiszhai.github.io/2017/09/30/tmux/)

[tmux 插件安装](https://www.cnblogs.com/hongdada/p/13528984.html)

[tmate 简明教程](https://www.cnblogs.com/idorax/p/12380758.html)
