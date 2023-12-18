import React, { useState, useEffect } from "react";
import ReactDOM from "react-dom";

const Modal = ({ isOpen, onClose, children }) => {
  const [isBrowser, setIsBrowser] = useState(false);

  useEffect(() => {
    setIsBrowser(true);
  }, []);

  const handleCloseClick = (e) => {
    e.preventDefault();
    onClose();
  };

  const modalContent = isOpen ? (
    <div className="fixed inset-0 z-50 flex overflow-auto bg-black bg-opacity-50 backdrop-blur">
      <div className="relative flex flex-col w-full max-w-md p-8 m-auto bg-white rounded-lg">
        <span className="absolute top-0 right-0 p-4">
          <button
            onClick={handleCloseClick}
            className="text-black close-modal"
            aria-label="Close"
          >
            &times;
          </button>
        </span>
        {children}
      </div>
    </div>
  ) : null;

  if (isBrowser) {
    return ReactDOM.createPortal(modalContent, document.getElementById("root"));
  } else {
    return null;
  }
};

export default Modal;
