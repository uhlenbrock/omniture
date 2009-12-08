class Omniture
  
  attr_accessor :events, :evars, :props
  mattr_reader :omniture_config
  
  OMNITURE_EVARS = { 'eVar1' => '', 'eVar2' => '', 'eVar3' => '', 'eVar4' => '', 'eVar5' => '' }
  OMNITURE_PROPS = { 'pageName' => '', 'server' => '', 'channel' => '', 'pageType' => '', 'prop1' => '', 'prop2' => '', 'prop3' => '', 'prop4' => '', 'prop5' => '', 'campaign' => '', 'state' => '', 'zip' => '', 'products' => '', 'purchaseID' => '' }
  
  def initialize
    unless @@omniture_config
      @@omniture_config = YAML.load_file("#{RAILS_ROOT}/config/omniture.yml").symbolize_keys
    end
    reset
  rescue
    to_stderr "Be sure to put omniture.yml into your config directory." 
    exit
  end
  
  def reset
    @events = []
    @evars = {}
    @props = {}
  end
  
  def add_events(events_as_symbol_or_array)
    events = events_as_symbol_or_array.is_a?(Symbol) ? [events_as_symbol_or_array] : events_as_symbol_or_array
    events.each do |event|
      event = event.to_s
      @events << config(:events)[event] if config(:events).has_key? event
    end
  end
  
  def add_props(props)
    props.stringify_keys.each_pair do |key, value|
      @props[config(:props)[key]] = value if config(:props).has_key? key
    end
  end
  
  def add_event_variables(pairs)
    pairs.stringify_keys.each_pair do |key, value|
      @evars[config(:evars)[key]] = value if config(:evars).has_key? key
    end
  end

  def print_page_code
    out = <<-OUT
      <!-- SiteCatalyst code version: H.20.3.
      Copyright 1996-2009 Adobe, Inc. All Rights Reserved
      More info available at http://www.omniture.com -->
      <script language="JavaScript" type="text/javascript">var s_account="#{account_config("s_account")}"</script>
      <script language="JavaScript" type="text/javascript" src="#{account_config("s_code")}"></script>
      <script language="JavaScript" type="text/javascript"><!--
      /* You may give each page an identifying name, server, and channel on the next lines. */
      
      #{print_events}
      #{print_evars(@evars)}
      #{print_props(@props)}
  
      /************* DO NOT ALTER ANYTHING BELOW THIS LINE ! **************/
      var s_code=s.t();if(s_code)document.write(s_code)//--></script>
      <script language="JavaScript" type="text/javascript"><!--
      if(navigator.appVersion.indexOf('MSIE')>=0)document.write(unescape('%3C')+'\!-'+'-')
      //--></script><noscript><a href="http://www.omniture.com" title="Web Analytics"><img
      src="http://#{account_config("trackingServer")}/b/ss/#{account_config("s_account")}/1/H.20.3--NS/0"
      height="1" width="1" border="0" alt="" /></a></noscript><!--/DO NOT REMOVE/-->
      <!-- End SiteCatalyst code version: H.20.3. -->
    OUT
    out
  end
  
  def print_rjs_code
    out = <<-OUT
      page << "var s = s_gi(s_account);"
      page << "#{print_evars(@evars)}"
      page << "#{print_props(@props)}"
      page << "#{print_events}"
    OUT
    out
  end
  
  def print_js_code
    out = <<-OUT
      <script language="JavaScript" type="text/javascript"><!--
        var s = s_gi(s_account);
        #{print_evars(@evars)}
        #{print_props(@props)}
        #{print_events}
      --></script>
    OUT
    out
  end
  
  private
  
    def print_evars(evars)
      out = ''
      evars.each_pair do |key,value|
        out << "s.#{key}='#{value}';\n"
      end
      out
    end
  
    def print_props(props)
      out = ''
      props.each_pair do |key,value|
        out << "s.#{key}='#{value}';\n"
      end
      out
    end
  
    def print_events
      out = ''
      unless @events.empty?
        out << "s.events='#{@events.join(",")}';\n"
      else
        out << "s.events='';\n"
      end
      out
    end
    
    def to_stderr(s)
      STDERR.puts "** [Omniture] " + s
    end
    
    def config(key)
      @@omniture_config[key]
    end
    
    def account_config(key)
      @@omniture_config[:account][Rails.env][key]
    end
  
end