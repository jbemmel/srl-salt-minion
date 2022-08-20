srlinux-22.6.1-281.bin:
  file.managed:
    - name: /tmp/srlinux-22.6.1-281.bin.dummy
    - source: salt://srlinux/srlinux-22.6.1-281.bin.dummy
    # - source_hash: 8c274391d1af650a9640a825e9cfbced