## The contents of this file are subject to the Common Public Attribution
## License Version 1.0. (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License at
## http://code.reddit.com/LICENSE. The License is based on the Mozilla Public
## License Version 1.1, but Sections 14 and 15 have been added to cover use of
## software over a computer network and provide for limited attribution for the
## Original Developer. In addition, Exhibit A has been modified to be
## consistent with Exhibit B.
##
## Software distributed under the License is distributed on an "AS IS" basis,
## WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
## the specific language governing rights and limitations under the License.
##
## The Original Code is reddit.
##
## The Original Developer is the Initial Developer.  The Initial Developer of
## the Original Code is reddit Inc.
##
## All portions of the code written by reddit are Copyright (c) 2006-2015
## reddit Inc. All Rights Reserved.
###############################################################################

<%!
   from r2.lib.strings import strings
   from r2.lib.pages import SubredditSelector, UserText
   from r2.lib.template_helpers import add_sr, _wsf, format_html
   from r2.lib.filters import safemarkdown
%>

<%namespace file="utils.m" import="error_field, submit_form, _a_buffered, text_with_links"/>
<%namespace name="utils" file="utils.m"/>

<%
  if thing.default_sr:
    sr = format_html("&#32;%s", unsafe(_a_buffered(thing.default_sr.name, href=thing.default_sr.path)))
  else:
    sr = _("Headquarter")
%>

<h1>${_wsf("submit to %(sr)s", sr=sr)}</h1>

<%utils:submit_form onsubmit="return post_form(this, 'submit', linkstatus, null, true)"
                    action=${add_sr("/submit")},
                    _class="submit content warn-on-unload",
                    _id="newlink">

%if thing.show_link and thing.show_self:
${thing.formtabs_menu}
%endif



<div class="formtabs-content">

<div class="spacer">
    %if thing.show_link:
        <div id="link-desc" class="infobar">${strings.submit_link}</div>
    %endif
    %if thing.show_self:
        <div id="text-desc" class="infobar">${strings.submit_text}</div>
    %endif
</div>


<script type="text/javascript">
function countChars(countfrom,displayto) {
  var len = document.getElementById(countfrom).value.length;
  document.getElementById(displayto).innerHTML = len;
}
</script>

<div class="spacer">
  <%utils:round_field title="${_('title')}" id="title-field">
    <textarea name="title" id="title_text" rows="2" required onkeyup="countChars('title_text','charcount');" onkeydown="countChars('title_text','charcount');" onmousemove="countChars('title_text','charcount');">${thing.title}</textarea><p align="right"><span align="right" id="charcount">0</span>/300</p>
    ${error_field("NO_TEXT", "title", "div")}
    ${error_field("TOO_LONG", "title", "div")}
  </%utils:round_field>
</div>

%if thing.show_link:
<div class="spacer">
  <%utils:round_field title="${_('url')}" id="url-field">
    <input name="kind" value="link" type="hidden"/>
    <input id="url" name="url" type="url" value="${thing.url}" required>
    ${error_field("NO_URL", "url", "div")}
    ${error_field("BAD_URL", "url", "div")}
    ${error_field("DOMAIN_BANNED", "url", "div")}
    ${error_field("ALREADY_SUB", "url", "div")}
    ${error_field("NO_LINKS", "sr")}
    ${error_field("NO_SELFS", "sr")}

    <div id="suggest-title">
      <span class="title-status"></span>
      <button type="button" tabindex="100" onclick="fetch_title()" onmouseup="countChars('title_text','charcount');" onmousemove="countChars('title_text','charcount');">${_("suggest title")}</button>
    </div>
  </%utils:round_field>
</div>
%endif

%if thing.show_self:
<div class="spacer">
  <%utils:round_field title="${_('text')}", description="${_('(optional)')}" id="text-field">
    <input name="kind" value="self" type="hidden"/>

    ${UserText(None, text = thing.text, have_form = False, creating = True)}

    ${error_field("NO_SELFS", "sr")}
  </%utils:round_field>
</div>
%endif

<div class="spacer">
  <%utils:round_field title="${_('choose a sub')}" id="reddit-field">
    ${SubredditSelector(thing.default_sr, extra_subreddits=thing.extra_subreddits, required=True)}
  </%utils:round_field>
</div>

<div class="spacer">
    <div class="submit_text roundfield">
        <h1>${_wsf('submitting to %(sr)s', sr=unsafe('/' + g.brander_community_abbr + '/<span class="sr"></span>'))}</h1>
        <span class="content md-container">
            %if thing.default_sr and thing.default_sr.submit_text:
                ${unsafe(safemarkdown(thing.default_sr.submit_text))}
            %endif
        </span>
    </div>
</div>

<div class="spacer">
  <%utils:round_field title="${_('options')}" id="sendreplies-field">
    <input class="nomargin" type="checkbox" ${'checked="checked"' if c.user.pref_sendreplies else ''} name="sendreplies" id="sendreplies" data-send-checked="true"/>
    <label for="sendreplies">
      ${_("send replies to my inbox")}
    </label>
  </%utils:round_field>
</div>

${thing.captcha}
    
</div>

<div class="roundfield info-notice">
  ${text_with_links(_("please be mindful of the %(content_policy)s"),
      content_policy=dict(
        link_text=_("content policy"),
        path="/s/Headquarter/comments/46/terms_and_content_policy/",
        target="_blank"),
      good_reddiquette=dict(
        link_text=_("good reddiquette"),
        path="/wiki/reddiquette",
        target="_blank"),
  )}
</div>

<input name="resubmit" value="${thing.resubmit}" type="hidden"/>
<div class="spacer">
  <button class="btn" name="submit" value="form" type="submit" onmousemove="countChars('title_text','charcount');">${_("submit")}</button>
  <span class="status"></span>
  ${error_field("RATELIMIT", "ratelimit")}
  ${error_field("INVALID_OPTION", "sr")}
  ${error_field("IN_TIMEOUT", "sr")}
</div>
</%utils:submit_form>

%if thing.show_self and thing.show_link:
<script type="text/javascript">
  $(function() {
  var form = $("#newlink");
  if(form.length) {
    var default_menu = form.find(".${thing.default_tab}-button:first");
    select_form_tab(default_menu, "${thing.default_show}", "${thing.default_hide}");
    }
  });
</script>
%endif

