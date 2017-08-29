class TangoCardV2::BrandImage < TangoCardV2::Base
  attr_reader :w80,
              :w130,
              :w200,
              :w278,
              :w300,
              :w1200

  def initialize(params)
    #-326ppi
    %w{ 80 130 200 278 300 1200 }.each do |param|
      eval "@w#{param} = params['#{param}w-326ppi']"
    end
  end

  def max_img
    %w{ 80 130 200 278 300 1200 }.reverse.each do |i_size|
      val = eval("@w#{i_size}")
      return val if val.present?
    end
  end

  def default_img
    def_img = TangoCardV2.configuration.default_image_size
    if def_img.present? && %w{ 80 130 200 278 300 1200 }.include?(def_img.to_s)
      eval "@w#{def_img}"
    else
      @w200
    end
  end

  def min_img
    %w{ 80 130 200 278 300 1200 }.each do |i_size|
      val = eval("@w#{i_size}")
      if val.present?
        return val
      end
    end
  end
end
