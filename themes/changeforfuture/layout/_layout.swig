<!doctype html>
<html class="theme-next {% if theme.use_motion %}use-motion{% endif %} {% if theme.scheme %}theme-next-{{ theme.scheme | lower }}{% endif %}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
</head>

<body>
  <div class="container-fluid {% block page_class %}{% endblock %}">
  <div class="row">
  <div class="col-xs-12"> 
      <div id="header" class="header">
      <div class="header-inner">
        {% include '_partials/header.swig' %}
      </div>
    </div>
  </div>
</div>
  <div class="row">
    {# <div class="headband"></div> #}
  <div class="col-xs-9">
    <div id="main" class="main">
      <div class="main-inner">
        <div id="content" class="content">
          {% block content %}{% endblock %}
        </div>
      </div>      
    </div>
</div>
<div class="col-xs-3">
  {% block sidebar %}{% endblock %}

</div>
</div>

<div class="row">
    <div id="footer" class="footer">
    <div class="row">
    <div class="col-xs-11">
      <div class="footer-inner">
        {% include '_partials/footer.swig' %}
      </div>
    </div>
    <div class="col-xs-1">
      <div class="back-to-top"></div>
    </div>
  </div>
    </div>
    </div>
</div>

  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery/index.js?v=2.1.3"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/bootstrap/bootstrap.min.js"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/velocity/velocity.min.js"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/velocity/velocity.ui.min.js"></script>

  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/siteJS/cube.js"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/siteJS/site.js"></script>

  {# This block is used to set options before any other scripts run #}
  {% block script_extra_before %}{% endblock %}

  {% include '_scripts/fancy-box.swig' %}
  {% include '_scripts/helpers.swig' %}

  {% block script_extra %}{% endblock %}

  {% include '_scripts/mathjax.swig' %}
  {% block comment_system %}{% endblock %}

  {% include '_scripts/analytics/google-analytics.swig' %}
</body>
</html>
