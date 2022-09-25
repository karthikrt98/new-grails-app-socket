package hello1

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin
import grails.converters.JSON


@CrossOrigin
@RestController
public class LiveChatController{

	def springSecurityService;

    @Autowired
    private SimpMessagingTemplate simpMessagingTemplate;

    def liveChatService
    def dataSource;

    // test method for checking live chats
    def index(){
    	render(view:'/liveChat/index')
    }

   	
   	// This method is mapped to send the socket message
   	//used in liveChat.js file as /app/chat/{userid}



    def sendSocketMessage={
        def data= request.JSON
        println("data reecived -- ${data}")
        liveChatService.sendSocketMessage(data.toUserId,data.message)
        return render([success:true] as JSON)
    }
   	

    def fetchAllUsers(){
        println("Fetching data");
        def data=[[
        	id:1,
        	name:'Admin'
        	],[id:2,
        		name:"Karthik"
        		]]

        render([data:data] as JSON)
        return
    }

}

