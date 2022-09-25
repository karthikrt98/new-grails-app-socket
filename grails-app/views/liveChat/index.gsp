<!doctype html>
 <html>
 <head>
     <meta name="layout" content="main"/>
     <title>Welcome to Grails</title>
     <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
     <!--    libs for stomp and sockjs-->
     <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.4.0/sockjs.js"></script>
     <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
     <!--    end libs for stomp and sockjs-->
     <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css" rel="stylesheet"
           type="text/css">
     <asset:link rel="icon" href="favicon.ico" type="image/x-ico" />
 </head>
 <body>
      <div class="search">
             <input id="userName" placeholder="search" type="text"/>
             <button id="connectToSocket">Enter the chat</button>
             <button onclick="fetchAll()">Refresh</button>
         </div>
    <div style="display:flex;">
        
         <div>
             <p>Current user --- <span id="currentUser"></span> </p>
             <p>Users</p>
             <ul class="usersList" name="usersList" id="usersList"></ul>
         </div>
             <div class="chat">
         <div class="chat-header clearfix">
             <div class="chat-about">
                 <div class="chat-with" id="selectedUserId"></div>
                 <div class="chat-num-messages"></div>
             </div>
             <i class="fa fa-star"></i>
         </div> <!-- end chat-header -->
 
         <div class="chat-history" id="chatHistoryList">
             <ul>
 
             </ul>
 
         </div> <!-- end chat-history -->
 
         <div class="chat-message clearfix">
             <textarea id="message-to-send" name="message-to-send" placeholder="Type your message" rows="3"></textarea>
 
             <i class="fa fa-file-o"></i> &nbsp;&nbsp;&nbsp;
             <i class="fa fa-file-image-o"></i>&nbsp;&nbsp;
 
             <button id="sendBtn">Send</button>
 
         </div> <!-- end chat-message -->
 
     </div> 
 
    </div>
<script type="text/javascript">
    var url=window.location.origin
    let stompClient;
    let selectedUser;
    let lastSentMsg;
    let newMessages = new Map();


    const server_options = {
        host:"stomp+ssl://b-e340d555-270a-4e4b-a73e-a7e8fb4d3519-1.mq.ap-southeast-1.amazonaws.com",
        port:61614,
        ssl: true,
        connectHeaders: {
            host: '/',
            'accept-version': '1.1',
            'heart-beat': '0,0', // no heart beat
            login: "stage-user",
            passcode: "vKNUrWASwDuU",
        },
    };

    function connectToChat(userName) {
        console.log("connecting to chat... ",userName)
        let socket = new SockJS(url+'/wsChat');
        stompClient = Stomp.over(socket);
        console.log("Trying to connect to chat server ... ${stompClient} ----")
        stompClient.connect({}, function (frame) {
            stompClient.subscribe("/topic/socketChat/user" + userName, function (response) {
                let data = JSON.parse(response.body).data;
                if (selectedUser === data.fromLogin) {
                    render(data);
                } else {
                    newMessages.set(data.fromLogin, data.message);
                    $('#username_' + data.fromLogin).append('<span id="newMessage_' + data.fromLogin + '" style="color: red">+1</span>');
                }
            });
        });
    }


    $('#sendBtn').bind('click',function(){
        $("#message-to-send").blur()
        var textMsg= $("#message-to-send").val();
        var from=$('#userId').val();
        $("#message-to-send").val('');
        sendMsg(from,textMsg);
    })

    $('#connectToSocket').click(function(){
        var userId= $('#userName').val();
        connectToChat(userId)

    })

    $('#refreshUser').click(function(){
        console.log("Get users")
        var userId= $('#userId').val();
        fetchAll()
    })

    function sendMsg(from, text, type="MESSAGE") {
        var data={
            fromLogin: from,
            message: text,
            type:type,
        }

        var postData={
            toUserId:selectedUser,
            message:data
        }
        console.log("post data --",postData)

        fetch("/liveChat/sendSocketMessage", {
            method: "POST",
            headers: {'Content-Type': 'application/json'}, 
            body: JSON.stringify(postData)
        }).then(res => {
            console.log("Request complete! response:", res);
            $('#message-to-send').html();
            render(data);
        });


        // stompClient.send("/topic/socketChat/user" + selectedUser, {}, JSON.stringify({data}));
       
        lastSentMsg=data;
            

    }

    function render(data) {
        scrollToBottom();
        // responses
        // var templateResponse = Handlebars.compile($("#message-response-template").html());
        console.log("data sent is--",data)
        var templateResponse= ''
        var lastMsgId= $('#chatHistoryList').children().last().attr('id');
        var currentUser=$('#userId').val();
        

        if(data.type=='MESSAGE'){
            templateResponse= '<li><div><div style="display:flex">\n <p>'+ data.fromLogin+'</p>\n'+
            '&nbsp;&nbsp;&nbsp;<p>'+getCurrentTime()+'</p>\n </div>'+
            '<p>'+data.message+'</p></div></li>';
        }
        else{
            templateResponse='<p id="typing">typing...</p>';
        }


        if(!data ||  (data.type=='TYPING' && data.fromLogin==currentUser) || lastMsgId=='typing' || (data.type!='TYPING' &&data.message=="")){
            return 
        }
        else{
            setTimeout(function () {
                $('#chatHistoryList').append(templateResponse);
                scrollToBottom();
            }.bind(this), 1500);
        }

        

        
    }

    function scrollToBottom() {
        $('#chatHistoryList').scrollTop($('#chatHistoryList')[0].scrollHeight);
    }


    function getCurrentTime() {
        return new Date().toLocaleTimeString().replace(/([\d]+:[\d]{2})(:[\d]{2})(.*)/, "$1$3");
    }

    function selectUser(userName){
        console.log("selecting users: " + userName);
        selectedUser = userName;
        let isNew = document.getElementById("newMessage_" + userName) !== null;
        if (isNew) {
            let element = document.getElementById("newMessage_" + userName);
            element.parentNode.removeChild(element);
            render(newMessages.get(userName), userName);
        }
        $('#selectedUserId').html('');
        $('#selectedUserId').append('Chat with ' + userName);
    }


    function fetchAll() {
        
        $.get(url + "/liveChat/fetchAllUsers", function (response) {
            let users = response.data;
            console.log("user data--",users)
            let fromLogin=document.getElementById("userName").value;
            let usersTemplateHTML = "";
            for (let i = 0; i < users.length; i++) {
                if(users[i]!=fromLogin){
                usersTemplateHTML = usersTemplateHTML + '<a href="#" onclick="selectUser(\'' + users[i].id + '\')">'+
                    '<li id="username_'+users[i].name+'">'+users[i].name+'</li>\n </a>';
                }
                
            }
            $('#usersList').html(usersTemplateHTML);
        });
    }
</script>
</body>

</html>