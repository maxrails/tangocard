class TangoCard::Base

  def attrs_list
    instance_variables.collect{|t| t.to_s.gsub('@','').to_sym}
  end

  def method_missing name, *args, &block
    if name == :[] && args.length == 1 && block.nil? && attrs_list.include?( args[0].to_sym )
      self.send(args[0].to_sym)
    else
      super
    end
  end

  def initialize_read_variables attrs_list, attrs_list_with_default, params

    if attrs_list.present?
      attrs_list.each do |itemName|
        eval "@#{itemName} = params['#{itemName}']"
      end
    end

    if attrs_list_with_default.present?
      attrs_list_with_default.each do |nameValue|
        eval "@#{nameValue[0]} = params['#{nameValue[0]}'] || #{nameValue[1]}"
      end
    end

  end

end