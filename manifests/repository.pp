# @summary
#   Manages the bareos repository
#
# @param version
#
class gernox_bareos::repository (
  String $version,
) {
  $url = "http://download.bareos.org/bareos/release/${version}/"
  $location = "${url}xUbuntu_${::operatingsystemrelease}"

  contain ::apt
  ::apt::source { 'bareos':
    location => $location,
    release  => '/',
    repos    => '',
    key      => {
      id     => 'A0CFE15F71F798574AB363DD118283D9A7862CEE',
      source => "${location}/Release.key",
    },
  }
  Apt::Source['bareos'] -> Package<|tag == 'bareos'|>
  Class['Apt::Update'] -> Package<|tag == 'bareos'|>
}
