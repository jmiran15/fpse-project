import { useEffect, useState } from "react";
import InputQuery from "./components/QueryInput";
import Modal from "./components/core/Modal";
import Messages from "./components/Messages";

// user message type
// {
//   id: uuid
//   role: "user",
//   content: "Hello"
// }

// assitant message type
// {
//   refid: uuid
//   role: "assistant",
//   nst: base64
//   content: base64,
//   content_similarity: float,
//   style_similarity: float,
//   style: base64
//   isLoading: true
// }

function App() {
  const [messages, setMessages] = useState([]); // { type: "user", text: "Hello" }

  const [isModalOpen, setIsModalOpen] = useState(false);
  const openModal = (messageId) => {
    setSelectedMessage(messageId);
    setIsModalOpen(true);
  };
  const closeModal = () => setIsModalOpen(false);

  console.log(messages);

  const [isLoading, setIsLoading] = useState(false); // [true, false, true, false
  const [selectedMessage, setSelectedMessage] = useState(null);

  let selected = messages.length
    ? messages.filter((m) => m.refid === selectedMessage)[0]
    : null;

  useEffect(() => {
    // disable everything in queryinput when there is a message with isLoading true
    messages.forEach((m) => {
      if (m.isLoading) {
        setIsLoading(true);
      }
    });
  }, [messages]);

  return (
    <div className="flex flex-col items-center justify-center h-screen py-10 bg-gray-100 App px-52 gap-y-2">
      <Modal isOpen={isModalOpen} onClose={closeModal}>
        {selected && (
          <div className="grid grid-cols-[50%_50%] w-full">
            <div className="flex flex-col pl-4 space-y-2 first-letter">
              <span className="p-2 text-gray-600">
                Content image: {selected.content_similarity}
              </span>

              <img
                src={`data:image/jpeg;base64,${selected.content_image}`}
                alt="Generated Content"
                className="w-full rounded-lg"
              />
            </div>
            <div className="flex flex-col pl-4 space-y-2 first-letter">
              <span className="p-2 text-gray-600">
                Style image: {selected.style_similarity}
              </span>
              <img
                src={`data:image/jpeg;base64,${selected.style_image}`}
                alt="Generated Content"
                className="w-full rounded-lg"
              />
            </div>
          </div>
        )}
      </Modal>
      <Messages
        messages={messages}
        setMessages={setMessages}
        openModal={openModal}
      />
      <InputQuery
        loading={isLoading}
        messages={messages}
        setMessages={setMessages}
      />
    </div>
  );
}

export default App;
