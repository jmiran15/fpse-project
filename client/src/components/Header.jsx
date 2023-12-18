const Header = () => {
  return (
    <div className="flex flex-col items-center justify-start w-full space-y-2">
      <img
        src={process.env.PUBLIC_URL + "/LOGO.png"}
        alt="Logo"
        className="object-contain w-32 h-32"
      />
      <h1 className="text-2xl font-bold text-gray-800">
        NST - Image Generator
      </h1>
      <p className="text-gray-600 text-md">
        Let me turn your imagination into imagery
      </p>
      <p className="text-sm text-gray-500">
        By Davina Oludipe, Jonathan Miranda
      </p>
    </div>
  );
};

export default Header;
