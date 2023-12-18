import { useEffect, useRef } from "react";
import AssistantMessage from "./AssistantMessage";
import Header from "./Header";
import UserMessage from "./UserMessage";

const Messages = ({ messages, setMessages, openModal }) => {
  const endOfMessagesRef = useRef(null);

  useEffect(() => {
    if (endOfMessagesRef.current) {
      endOfMessagesRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages]); // Dependency array includes messages, so it runs every time messages change

  console.log("Messages: ", messages);
  return (
    <div className="flex-1 w-full overflow-auto">
      <Header />

      {messages.map((message, index) => {
        if (message.role === "assistant") {
          return (
            <AssistantMessage
              key={message.refid + "assistant"}
              message={message}
              openModal={openModal}
            />
          );
        } else {
          return <UserMessage key={message.id + "user"} message={message} />;
        }
      })}
      {/* Add an element to serve as the scroll target */}
      <div ref={endOfMessagesRef} />
    </div>
  );
};

export default Messages;
