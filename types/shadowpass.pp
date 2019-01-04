# /etc/shadow password allowed values
type Simplib::ShadowPass = Variant[
  Enum['*','!','!!'],
  Pattern['^((!.*)|(\$(1|2(a|y)?|3|md5|sha1|5|6)\$.+))$']
]
