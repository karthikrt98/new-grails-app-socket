package hello1

import grails.transaction.Transactional
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;

@Transactional
class LiveChatService {

    @Autowired
    private SimpMessagingTemplate simpMessagingTemplate;

    def serviceMethod() {

    }

     def sendSocketMessage(def toUserId,def data){
        def connectedIds;
        // we create a unique id using the two users to send socket messages between them
        println("Bedore sending message ${new Date()}")
        connectedIds = toUserId
    	def url="/topic/socketChat/user"+connectedIds
        data=data.toString()
    	simpMessagingTemplate.convertAndSend(url, [data:data])
        println("After sending message ${new Date()}")
    	
    }
}
