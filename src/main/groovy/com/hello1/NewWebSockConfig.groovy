package com.hello1;

import grails.plugin.springwebsocket.GrailsSimpAnnotationMethodMessageHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.SubscribableChannel;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.AbstractWebSocketMessageBrokerConfigurer;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
// import org.springframework.messaging.tcp.reactor.ReactorNettyTcpClient;
// import org.springframework.messaging.simp.stomp.StompReactorNettyCodec

@Configuration
@EnableWebSocketMessageBroker
@EnableWebSocket
public class NewWebSockConfig implements WebSocketMessageBrokerConfigurer {


	@Override
	public void registerStompEndpoints(StompEndpointRegistry stompEndpointRegistry) {
		stompEndpointRegistry.addEndpoint("/wsChat").setAllowedOrigins("*").withSockJS();
	}
/* 
activeMq.url="b-e340d555-270a-4e4b-a73e-a7e8fb4d3519-1.mq.ap-southeast-1.amazonaws.com"
activeMq.portNo=61614
activeMq.username="stage-user"
activeMq.password="vKNUrWASwDuU"

 */

	@Override
	public void configureMessageBroker(MessageBrokerRegistry messageBrokerRegistry) {

		messageBrokerRegistry.enableStompBrokerRelay("/topic")
		.setRelayHost('ec2-54-254-111-10.ap-southeast-1.compute.amazonaws.com')
		.setRelayPort(61613)
		.setClientLogin("admin")
		.setClientPasscode("kGWuPG49nb");
		messageBrokerRegistry.setApplicationDestinationPrefixes("/app2");
	}





	public void addArgumentResolvers(java.util.List list){}
	public void addReturnValueHandlers(java.util.List list){}
	public void configureWebSocketTransport(org.springframework.web.socket.config.annotation.WebSocketTransportRegistration wstr){}
	public void configureClientOutboundChannel(org.springframework.messaging.simp.config.ChannelRegistration cr){}
	public boolean configureMessageConverters(java.util.List list){
		return true;
	}
	public void configureClientInboundChannel(org.springframework.messaging.simp.config.ChannelRegistration cr){}

	@Bean
	GrailsSimpAnnotationMethodMessageHandler grailsSimpAnnotationMethodMessageHandler(
		MessageChannel clientInboundChannel,
		MessageChannel clientOutboundChannel,
		SimpMessagingTemplate brokerMessagingTemplate
	) {
		def handler = new GrailsSimpAnnotationMethodMessageHandler(clientInboundChannel, clientOutboundChannel, brokerMessagingTemplate)
		handler.destinationPrefixes = ["/app2"]
		return handler
	}
	
}

