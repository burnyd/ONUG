base:
  {% for index in range(1, 3) -%}
  'spine{{ index }}':
    - spine{{ index }}
  {% endfor -%}
  '*':
    - bgp-as
  'leaf*':
    - beacon
  'spine*':
    - beacon
  'leaf1':
    - leaf1
  'leaf2':
    - leaf2
  'leaf3':
    - leaf3
  'leaf4':
    - leaf4
