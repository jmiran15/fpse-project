import { useRef } from "react";

const Textarea = ({
  minLines,
  maxLines,
  placeholder,
  value,
  setValue,
  isLoading,
}) => {
  const textareaRef = useRef(null);

  const handleChange = (event) => {
    const textareaLineHeight = 24; // Define the line height for the textarea
    const previousHeight = event.target.style.height;
    event.target.style.height = "auto"; // Reset height to recalculate

    const currentHeight = event.target.scrollHeight;
    const currentRows = Math.floor(currentHeight / textareaLineHeight);

    if (currentRows < minLines) {
      event.target.style.height = `${minLines * textareaLineHeight}px`;
    } else if (currentRows > maxLines) {
      event.target.style.height = `${maxLines * textareaLineHeight}px`;
      event.target.scrollTop = event.target.scrollHeight;
    } else {
      event.target.style.height = `${currentHeight}px`;
    }

    if (previousHeight !== event.target.style.height) {
      textareaRef.current.rows =
        currentRows >= maxLines ? maxLines : currentRows;
    }
    setValue(event.target.value);
  };

  return (
    <textarea
      disabled={isLoading}
      value={value}
      ref={textareaRef}
      rows={minLines}
      placeholder={placeholder}
      className="p-2 overflow-auto border border-gray-300 rounded-md resize-y focus:outline-none focus:ring-2 focus:ring-blue-500"
      style={{
        lineHeight: "24px",
        minHeight: `${minLines * 24}px`,
        maxHeight: `${maxLines * 24}px`,
      }}
      onChange={handleChange}
    />
  );
};

export default Textarea;
