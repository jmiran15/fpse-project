const Badge = ({ text }) => {
  return (
    <span className="text-xs font-semibold inline-block py-1 px-2.5 uppercase rounded-full text-blue-600 bg-blue-200 last:mr-0 mr-1">
      {text}
    </span>
  );
};

export default Badge;
