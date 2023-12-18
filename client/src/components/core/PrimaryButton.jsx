const PrimaryButton = ({
  disabled = false,
  children,
  icon,
  size = "lg",
  onClick = () => {},
}) => {
  const sizeClasses = {
    lg: "py-2 px-4 text-lg",
    md: "py-1.5 px-3 text-md",
    sm: "py-1 px-2 text-sm",
  };

  return (
    <button
      className={`bg-blue-500 hover:bg-blue-700 text-white font-bold rounded ${
        sizeClasses[size]
      } ${disabled && "opacity-50 cursor-not-allowed"}}`}
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

export default PrimaryButton;
