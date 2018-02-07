require 'thor'
require 'figaro'
require 'curb'
require 'mechanize'
require 'awesome_print'


require 'spree_store_tools/cli/tools'
require 'spree_store_tools/session_manager'
require 'spree_store_tools/api_helper'

module SpreeStoreTools
  class HammerOfTheGods < Thor
    class_option :verbose, :type => :boolean, :default=>false, :desc=>"if verbose set to true then will print out progress and status messages, but only works with format text"
    class_option :env, :type => :string, :default=>'development', :desc=>"Same as rails environments: development or production, usually"
    class_option :format, :type => :string, :default=>'text', :desc=>"What kind of response is output ? text, yaml, or json"

    desc "free ", "This will make something free in the store to the user"
    long_desc <<-HELLO_WORLD
    `free --user=ID --variant=OTHER_ID --format=json --env=prodution ` will make a free item in the store
    assigns enough store credit to purchase the variant, and then buys it for the user
    uses an admin login stored in the appliation.yml of this gem
    returns info by printing out a  response (text, json, or yaml) defined by the --format flag

    HELLO_WORLD
    option :user, :type => :numeric,:required=> true,  :desc=> "User id who will get the free stuff"
    option :sku, :type => :string,:required=> true,  :desc=> "Variant sku listed in the shop"
    def free
      sku = options[:sku]
      user_id = options[:user].to_i
      s = SessionManager.new(user_id: user_id, env:  options[:env])
      h = ApiHelper.new(session_manager: s)
      info = h.get_variant_info(sku:sku)
      price = info['price'].to_f  # will throw exception if cannot find the variant
      credit_level = h.give_credit(amount:price)
      raise "cannot raise credit level enough" unless credit_level >= price
      #buy item
      #
      # make a new order
      # make a new line item
      # advance steps to the payment
      # call apply_credits_to_order
      # advance steps to completed
      # capture all credit payments

    end

    desc "price", "Will show price of a variant in the store"
    long_desc <<-HELLO_WORLD
    `price  --variant=OTHER_ID --format=json --env=prodution ` Will show price of a variant in the store
    uses an admin login stored in the appliation.yml of this gem
    returns info by printing out a  response (text, json, or yaml) defined by the --format flag

    HELLO_WORLD
    option :sku, :type => :string,:required=> true,  :desc=> "Variant sku listed in the shop"
    option :full, :type => :boolean, :default=>true,:desc=> "If full is off, then only return price "
    def variant
      sku = options[:sku]
      s = SessionManager.new(env:  options[:env])
      h = ApiHelper.new(session_manager: s)
      info = h.get_variant_info(sku:sku)
      b_full = options[:full]

      if b_full
        SpreeStoreTools::print_with_format(ret:info,format:options[:format])
      else
        SpreeStoreTools::print_with_format(ret:info['price'],format:options[:format])
      end

    end

    desc "credit", "Sets Credit for User"
    long_desc <<-HELLO_WORLD
    `credit  --user=ID --amount=?? --format=json --env=prodution ` Will show price of a variant in the store
    adds to a user's credit, returns the current credit

    HELLO_WORLD
    option :user, :type => :numeric,:required=> true,  :desc=> "User id to give credit to"
    option :amount, :type => :numeric,:required=> true,  :desc=> "Price of the credit to give"
    def credit
      amount = options[:amount].to_f
      user_id = options[:user].to_i
      s = SessionManager.new(user_id: user_id, env:  options[:env])
      feedback = s.post(path: 'users/add_credits',params:{user_id:user_id,amount: amount})
      SpreeStoreTools::print_with_format(ret:feedback,format:options[:format])
    end



    desc "store COMMANDS", "Tools for the user and the store"
    subcommand "tools", SpreeStoreTools::CLI::Tools
  end


end