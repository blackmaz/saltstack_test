/www_root/file_test.txt:
  file.managed:
    - source: salt://file_test.txt
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      custom_var: "default value"
      other_var: 123

file_add_line:
  file.accumulated:
    - filename: /www_root/file_test.txt
    - text: ' jumps over the lazy dog.'
    - require_in:
      - file: /www_root/file_test.txt

file_append_line:
  file.append:
    - name: /www_root/file_test.txt
    - text: Trust no one unless you have eaten much salt with him.
    - require:
      - file: file_add_line

file_append_lines:
  file.append:
    - name: /www_root/file_test.txt
    - text: 
      - Trust no one unless you have eaten much salt with him.
      - ""
      - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    - require:
      - file: file_append_line

file_append_multilines:
  file.append:
    - name: /www_root/file_test.txt
    - text: |
        Thou hadst better eat salt with the Philosophers of Greece,
        than sugar with the Courtiers of Italy.
        - Benjamin Franklin
    - require:
      - file: file_append_lines

{% set myvar = 42 %}
hosts-config-block-{{ myvar }}:
  file.blockreplace:
    - name: /www_root/file_test.txt
    - marker_start: "# START managed zone {{ myvar }} -DO-NOT-EDIT-"
    - marker_end: "# END managed zone {{ myvar }} --"
    - content: 'First line of content'
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True
