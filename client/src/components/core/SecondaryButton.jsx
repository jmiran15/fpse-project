const SecondaryButton = ({
  children,
  icon,
  size = "lg",
  disabled = false,
  onClick = () => {},
}) => {
  const sizeClasses = {
    lg: "py-2 px-4 text-lg",
    md: "py-1.5 px-3 text-md",
    sm: "py-1 px-2 text-sm",
  };

  return (
    <button
      className={`bg-transparent hover:bg-gray-100 text-gray-700 font-semibold hover:text-black border border-gray-500 hover:border-transparent rounded ${
        sizeClasses[size]
      } ${disabled && "opacity-50 cursor-not-allowed"}`}
      disabled={disabled}
      onClick={onClick}
    >
      {icon && (
        <img
          src={icon}
          alt="Icon"
          className="inline-block w-4 h-4 mr-2 -mt-1"
        />
      )}
      {children}
    </button>
  );
};

export default SecondaryButton;
