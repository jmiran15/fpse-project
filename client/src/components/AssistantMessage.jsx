import Loader from "./core/Loader";
import PrimaryButton from "./core/PrimaryButton";
import SecondaryButton from "./core/SecondaryButton";

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

const AssistantMessage = ({ message, openModal }) => {
  const downloadImage = (base64, fileName = "download.png") => {
    const link = document.createElement("a");
    link.href = base64;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="flex items-start py-4 space-x-4">
      <img
        src={process.env.PUBLIC_URL + "/LOGO.png"}
        alt="NST assistant logo"
        className="object-cover w-12 h-12 rounded-lg"
      />
      <div className="flex flex-col justify-start w-full">
        <span className="font-bold text-gray-700">NST - Image Generator</span>

        {message.isLoading ? (
          <Loader />
        ) : (
          <>
            <div className="my-2">
              <img
                src={`data:image/jpeg;base64,${message.nst}`}
                alt="Generated Content"
                className="w-1/2 rounded-lg"
              />
            </div>
            <div className="flex space-x-2">
              <PrimaryButton
                size="sm"
                icon="/download.svg"
                onClick={() =>
                  downloadImage(`data:image/jpeg;base64,${message.nst}`)
                }
              >
                Download
              </PrimaryButton>
              <SecondaryButton
                size="sm"
                icon="/bug.svg"
                onClick={() => openModal(message.refid)}
              >
                View logs
              </SecondaryButton>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default AssistantMessage;
