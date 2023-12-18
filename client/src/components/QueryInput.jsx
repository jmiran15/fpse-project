import Textarea from "./core/Textarea";
import PrimaryButton from "./core/PrimaryButton";
import SecondaryButton from "./core/SecondaryButton";
import { useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { flushSync } from "react-dom";

const InputQuery = ({ messages, setMessages, isLoading }) => {
  const [query, setQuery] = useState("");

  let disableSendButton =
    isLoading ||
    query === "" ||
    (messages.length > 0 && messages[messages.length - 1].role === "user")
      ? true
      : false;

  let disableClearButton = isLoading || messages.length === 0 ? true : false;

  const handleClear = () => setMessages([]);

  const handleSend = async () => {
    let id = uuidv4();
    let q = { id, role: "user", content: query };

    setMessages([
      ...messages,
      q,
      {
        refid: id,
        role: "assistant",
        isLoading: true,
      },
    ]);

    setQuery("");

    sendQuery(q);
  };

  function sendQuery(q) {
    let body = { query: q.content };

    console.log("Sending query: ", body);
    fetch("http://localhost:8080/query", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        flushSync(() => {
          // Use functional update to ensure we have the latest state
          setMessages((currentMessages) => {
            const index = currentMessages.findIndex(
              (m) => m.refid === q.id && m.role === "assistant"
            );
            if (index !== -1) {
              // Found the loading assistant message, update it
              const newMessages = [...currentMessages];
              newMessages[index] = {
                ...newMessages[index],
                nst: data.result_image,
                content_image: data.content_image,
                style_image: data.style_image,
                content_similarity: data.content_similarity,
                style_similarity: data.style_similarity,
                isLoading: false,
              };
              return newMessages;
            } else {
              // Loading assistant message not found, append new message
              return [
                ...currentMessages,
                {
                  refid: q.id,
                  role: "assistant",
                  nst: data.result_image,
                  content_image: data.content_image,
                  style_image: data.style_image,
                  content_similarity: data.content_similarity,
                  style_similarity: data.style_similarity,
                  isLoading: false,
                },
              ];
            }
          });
        });
        console.log("Success:", data);
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  return (
    <div className="grid grid-cols-[80%_20%] w-full">
      <div className="flex flex-col justify-start w-full">
        <Textarea
          isLoading={isLoading}
          value={query}
          setValue={setQuery}
          minLines={1}
          maxLines={5}
          placeholder="Type your query here..."
        />
      </div>
      <div className="flex flex-col pl-4 space-y-2 first-letter">
        <PrimaryButton disabled={disableSendButton} onClick={handleSend}>
          Send
        </PrimaryButton>
        <SecondaryButton disabled={disableClearButton} onClick={handleClear}>
          Clear
        </SecondaryButton>
      </div>
    </div>
  );
};

export default InputQuery;
