{%- from "exim/map.jinja" import exim with context -%}

{%- set virtual_aliases = salt['pillar.get']('exim:virtual_aliases', {}) -%}

{%- for name, targets in salt['pillar.get']('exim:aliases', {})|dictsort %}
exim-alias-{{ name }}:
{%- if not targets %}
  alias.absent:
    - name: {{ name }}
{%- else %}
  alias.present:
    - name: {{ name }}
    - target:
  {%- if targets is list %}
    {%- for target in targets %}
      - {{ target }}
    {%- endfor %}
  {%- else %}
        {{ targets }}
  {%- endif %}
{%- endif %}
{% endfor %}

{% if virtual_aliases -%}
exim-virtual-aliases-dir:
  file.directory:
    - name: {{ exim.virtual_aliases_dir }}
{%- endif %}

{% for domain, aliases in virtual_aliases|dictsort %}
exim-virtual-aliasas-{{ domain }}:
  file.managed:
    - name: {{ exim.virtual_aliases_dir }}/{{ domain }}
    - source: salt://exim/files/virtual_aliases.jinja
    - template: jinja
    - context:
        aliases: {{ aliases|json }}
        domain: {{ domain }}
{% endfor %}
