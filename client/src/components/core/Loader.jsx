const Loader = () => {
  return (
    <div className="flex self-start justify-start pt-4 pl-4">
      <div className="relative">
        <div className="absolute inset-0 flex items-center justify-center">
          <img
            src={process.env.PUBLIC_URL + "/photo.svg"}
            alt="Loading"
            className="w-6 h-6"
          />
        </div>
        <div className="w-12 h-12 border-b-4 border-blue-500 rounded-full animate-spin"></div>
      </div>
      <span className="p-2 text-gray-600">Creating image</span>
    </div>
  );
};

export default Loader;
