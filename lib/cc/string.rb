class String
  def numeric?
    Float(self) != nil rescue false
  end

  def to_st_date
    split_via_comma = self.split(",")
    st_year = split_via_comma.last.sp! # YEAR
    st_month = split_via_comma.first.partition(/\d/).first.sp!
    st_day = split_via_comma.first.partition(/\d/).last.sp!
    Date.strptime("#{st_month} #{st_day}, #{st_year}", '%B %d, %Y')
  end

  # Remove space!
  def sp!
    self.gsub(/[[:space:]]/, '')
  end

  def blank?
    self.to_s.empty?
  end
end
