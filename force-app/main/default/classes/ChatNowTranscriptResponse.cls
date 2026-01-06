/**
* @date 25/05/2023
* @description : Wrapper Class for GetChatNowTranscriptCtrl
**/
public class ChatNowTranscriptResponse {

	public class NewParty_Z {
		public UserInfo UserInfo;
		public UserData UserData;
		//public cls_EventAttributes EventAttributes;
	}

	public class Message {
		public Text Text;
		//public cls_EventAttributes EventAttributes;
	}

	public class UserData {
		public String Key;
		public String Value;
	}

	public class UserInfo {
		public String PersonId;
		public String UserNick;
		public String UserType;
		public String ProtocolType;
		public String TimeZoneOffset;
		public String ClientVersion;
	}

	public class Text {
		public String Type;
		public String Value;
	}

	public class Data {
		public String StartAt;
		public String SessionId;
		public List<Events> Events;
	}

	public Data Data;
	public cls_Problem Problem; //String Problem;

	public class Reason {
		public String Code;
		public String Value;
	}

	public class NewParty {
		public UserInfo UserInfo;
		public List<UserData> UserData;
		//public cls_EventAttributes EventAttributes;
	}

	public class Events {
		public String UserId;
		public String TimeShift;
		public String Visibility;
		public String EventId;
		public NewParty NewParty;
		public Message_Z Message;
		public PartyLeft PartyLeft;
	}

	public class Text_Z {
		public String Type;
		public String Value;
	}

	public class PartyLeft {
		public String AskerId;
		public Reason Reason;
	}

	public class Message_Z {
		public Text_Z Text;
		//public cls_EventAttributes EventAttributes;
	}

	//public class cls_EventAttributes {
	//}
    
    public class cls_EventAttributes {
		public cls_Item Item;
	}
	public class cls_Item {
		public cls_Item Item;
		public String Key;	//content
		public String Value;	//{  type : Message,  contentType : quick-replies,  messageType : text,  text : ,  content : [ {    id : 1,    type : quick-reply,    action : message,    text : Contact us later  }, {    id : 2,    type : quick-reply,    action : message,    text : Call 866-223-8034 for urgent issues  }, {    id : 3,    type : quick-reply,    action : message,    text : Request a callback  } ]}
	}
	public class cls_Text {
	}
    
	public class cls_Message {
	}
	public class cls_PartyLeft {
	}
	public class cls_Problem { 
        public String title; //"title": "Bad Request",
    	public Integer status; //"status": 400,
        public List<cls_Error> errors; //"errors": [{ "code": "404","message": "No data found"}]
	}
    
    public class cls_Error {
        public String code; //"code": "404"
        public String message; // "message": "No data found" 
    }
    
	public static ChatNowTranscriptResponse parse(String json) {
		return (ChatNowTranscriptResponse) System.JSON.deserialize(json, ChatNowTranscriptResponse.class);
	}
}