(function () {
  var config = window.OPENCLAW_GUIDE_CONFIG;

  if (!config) {
    return;
  }

  function setText(selector, valueMap) {
    document.querySelectorAll(selector).forEach(function (node) {
      var key = node.getAttribute("data-config");
      if (Object.prototype.hasOwnProperty.call(valueMap, key)) {
        node.textContent = valueMap[key];
      }
    });
  }

  function setLinks(selector, valueMap) {
    document.querySelectorAll(selector).forEach(function (node) {
      var key = node.getAttribute("data-config-href");
      if (Object.prototype.hasOwnProperty.call(valueMap, key)) {
        node.setAttribute("href", valueMap[key]);
      }
    });
  }

  function fallbackCopy(text) {
    var textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.left = "-9999px";
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand("copy");
    document.body.removeChild(textarea);
  }

  var values = {
    projectName: config.projectName,
    repoSlug: config.repoSlug,
    releaseTag: config.releaseTag,
    helpUrl: config.helpUrl,
    rawInstallUrl: config.rawInstallUrl,
    installCommand: config.installCommand,
    skipModelCommand: config.skipModelCommand,
    rawTelegramUrl: config.rawTelegramUrl,
    telegramCommand: config.telegramCommand,
    telegramStatusCommand: config.telegramStatusCommand
  };

  setText("[data-config]", values);
  setLinks("[data-config-href]", values);

  document.querySelectorAll("[data-copy-command]").forEach(function (button) {
    var originalLabel = button.getAttribute("aria-label") || "Copy command";
    var originalTitle = button.getAttribute("title") || originalLabel;

    function markCopied() {
      button.classList.add("is-copied");
      button.setAttribute("aria-label", "Copied");
      button.setAttribute("title", "Copied");

      window.setTimeout(function () {
        button.classList.remove("is-copied");
        button.setAttribute("aria-label", originalLabel);
        button.setAttribute("title", originalTitle);
      }, 1800);
    }

    button.addEventListener("click", function () {
      var copyKey = button.getAttribute("data-copy-key") || "installCommand";
      var textToCopy = values[copyKey] || config.installCommand;
      var copied = false;

      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(textToCopy).then(function () {
          markCopied();
        }).catch(function () {
          fallbackCopy(textToCopy);
          markCopied();
        });
        copied = true;
      }

      if (!copied) {
        fallbackCopy(textToCopy);
        markCopied();
      }
    });
  });
}());
