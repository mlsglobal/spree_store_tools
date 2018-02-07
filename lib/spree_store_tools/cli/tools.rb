

module SpreeStoreTools
  module CLI
    class Tools < Thor
      desc "api", "Runs the API as non admin user"
      long_desc <<-WHAT_I_AM
        for testing out the api as a non admin user
        returns full results
      WHAT_I_AM
      option :user, :type => :numeric,:required=> true,  :aliases => "-u",  :desc=> "User id to ask about"
      option :command, :type => :string,:required=> true,  :desc=> "the path of the command"
      option :action, :type => :string, :default=>'GET',  :desc=> "GET|POST|PUT|DELETE"
      option :json, :type => :string,:default=> '{}',  :desc=> "the input data to the command in json "
      def api
        user_id = options[:user].to_i
        s = SessionManager.new(user_id: user_id, env:  options[:env])
        data = JSON.parse(options[:json])
        ret = s.api(path: options[:command],admin:false,data:data,action:options[:action])
        SpreeStoreTools::print_with_format(ret:ret,format:options[:format])
      end


      desc "login_test", "Used to Test the User login and display user spree info "
      long_desc <<-WHAT_I_AM
        This will output the status of the login attempt
        Usefull for testing and diagnostics
      WHAT_I_AM
      option :user, :type => :numeric,:required=> true,  :desc=> "User id to test with"
      def login_test
        user_id = options[:user]
        s = SessionManager.new(user_id:user_id,env:  options[:env])
        what = s.api(path:'users/'+ user_id.to_s,admin:true)
        SpreeStoreTools::print_with_format(ret:what,format:options[:format])
      end
    end


  end
end