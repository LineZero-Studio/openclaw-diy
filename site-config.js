(function () {
  var repoOwner = "LineZero-Studio";
  var repoName = "openclaw-diy";
  var releaseTag = "v0.1.0";
  var rawInstallUrl = "https://raw.githubusercontent.com/" + repoOwner + "/" + repoName + "/" + releaseTag + "/install.sh";
  var rawTelegramUrl = "https://raw.githubusercontent.com/" + repoOwner + "/" + repoName + "/" + releaseTag + "/scripts/add-telegram.sh";

  window.OPENCLAW_GUIDE_CONFIG = Object.freeze({
    projectName: "OpenClaw VPS Guide",
    repoOwner: repoOwner,
    repoName: repoName,
    repoSlug: repoOwner + "/" + repoName,
    releaseTag: releaseTag,
    helpUrl: "https://linezerostudio.com",
    installPath: "install.sh",
    rawInstallUrl: rawInstallUrl,
    rawTelegramUrl: rawTelegramUrl,
    installCommand: "curl -fsSL " + rawInstallUrl + " | bash",
    skipModelCommand: "curl -fsSL " + rawInstallUrl + " | bash -s -- --skip-model",
    telegramCommand: "curl -fsSL " + rawTelegramUrl + " | bash",
    telegramStatusCommand: "sudo -u openclaw -H bash -lc 'openclaw channels status --channel telegram --probe --json'"
  });
}());
