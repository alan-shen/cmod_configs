## Bash completion for the Android SDK tools.
##
## Copyright (c) 2009 Matt Brubeck
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.

function _fastboot()
{
  local cur prev opts cmds c subcommand device_selected
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-w -s -p -c -i -b -n"
  cmds="update flashall flash erase getvar boot devices \
        reboot reboot-bootloader oem continue"
  subcommand=""
  partition_list="boot recovery system userdata radio fastboot"
  oemcmds="toadb startftm getsn check_cputype checksum \
	  fpt_writeitem fpt_writevalidbit fpt_closemnf \
	  txemanuf_eof_test txemanuf_bist_test erase repart \
	  write_osip_header start_partitioning partition retrieve_partitions stop_partitioning \
	  get_batt_info backup_factory restore_factory fastboot2adb reboot fru uniqueid \
	  get-spid get-fru get-part-id get-lifetime start-update cancel-update finalize-update remove-token \
	  nvm enable_flash_logs disable_flash_logs \
	  dnx_timeout"
  flashcmds="update system factory adb_config_file \
	  rnd_read rnd_write rnd_erase \
	  radio radio_fuse radio_erase_all radio_fuse_only radio_img \
	  token txemanuf ulpmc capsule token_umip \
	  fpt_ifwi fpt_txe fpt_pdr fpt_bios fpt_fpfs \
	  splashscreen dnx ifwi testos boot recovery fastboot ESP"
  erasecmds="factory system cache config logs data"
  device_selected=""

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    if [ "$word" = "-s" ]; then
      device_selected=true
    fi
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    c=$((++c))
  done

  case "${subcommand}" in
    '')
      case "${prev}" in
        -s)
          # Use 'fastboot devices' to list serial numbers.
          COMPREPLY=( $(compgen -W "$(fastboot devices|cut -f1)" -- ${cur} ) )
          return 0
          ;;
      esac
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          return 0
          ;;
      esac
      if [ -z "$device_selected" ]; then
        local num_devices=$(( $(fastboot devices 2>/dev/null|wc -l) ))
        if [ "$num_devices" -gt "1" ]; then
          # With multiple devices, you must choose a device first.
          COMPREPLY=( $(compgen -W "-s" -- ${cur}) )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
      return 0
      ;;
    flash)
      # partition name
      COMPREPLY=( $(compgen -W "${flashcmds}" -- ${cur}) )
      return 0
      ;;
    erase)
      # partition name
      COMPREPLY=( $(compgen -W "${erasecmds}" -- ${cur}) )
      return 0
      ;;
    oem)
      # partition name
      COMPREPLY=( $(compgen -W "${oemcmds}" -- ${cur}) )
      return 0
      ;;
  esac
}
complete -o default -F _fastboot fastboot
