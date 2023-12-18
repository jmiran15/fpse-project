const UserMessage = ({ message }) => {
  return (
    <div className="flex items-center py-4 space-x-4">
      <img
        src={process.env.PUBLIC_URL + "/PROFILE.png"}
        alt="User"
        className="object-cover w-12 h-12 rounded-lg"
      />
      <div>
        <span className="font-bold text-gray-700">You</span>
        <p className="text-gray-600">{message.content}</p>
      </div>
    </div>
  );
};

export default UserMessage;
