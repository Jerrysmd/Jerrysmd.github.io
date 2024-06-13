# Extension Project: Weibo Content Filter Ⅱ


Update the GitHub project https://github.com/Jerrysmd/weibo-content-filter. Add popup page and allow for custom configurations

<!--more-->

## Extension 1 step: Config manifest.json

1. **content_scripts**: Injects scripts into web pages that match specified URLs, runs at document start.
2. **permissions**: Defines the APIs the extension needs access to, like browser storage.
3. **action**: Specifies the popup displayed when the user clicks the extension icon.
4. **background**: Runs scripts in the background, even when the popup is not open.

```json
{
  "name": "大眼夹（新版微博）",
  "short_name": "大眼夹",
  "version": "0.1",
  "manifest_version": 3,
  "description": "新版微博非官方插件，去除时间线上的推荐、推广和广告微博。",
  "icons": {
    "48": "images/weiboFilter.png",
    "128": "images/weiboFilter.large.png"
  },
  "content_scripts": [
    {
      "matches": [
        "https://weibo.com/*",
        "https://www.weibo.com/*",
        "https://d.weibo.com/*",
        "http://d.weibo.com/*",
        "http://weibo.com/*",
        "http://www.weibo.com/*"
      ],
      "js": [
        "main.js"
      ],
      "run_at": "document_start"
    }
  ],
  "permissions": [
    "storage"
  ],
  "action": {
    "default_popup": "popup.html"
  },
  "background": {
    "service_worker": "background.js"
  }
}
```

## Extension 2 step: Setup popup HTML and JS

1. The `DOMContentLoaded` event ensures the code runs after the popup's HTML is loaded.
2. The `addEventListener` attaches handlers to the checkboxes, updating the browser's storage when their state changes.

```js
document.addEventListener('DOMContentLoaded', function () {
  chrome.storage.sync.get(['hotPush', 'recommend', 'mediaRecommend', 'ad', 'fansTop'], function (items) {
    document.getElementById('hotPush').checked = items.hotPush || false;
    document.getElementById('recommend').checked = items.recommend || false;
    document.getElementById('mediaRecommend').checked = items.mediaRecommend || false;
    document.getElementById('ad').checked = items.ad || false;
    document.getElementById('fansTop').checked = items.fansTop || false;
  });

  document.getElementById('hotPush').addEventListener('change', function () {
    chrome.storage.sync.set({ 'hotPush': this.checked });
  });
  document.getElementById('recommend').addEventListener('change', function () {
    chrome.storage.sync.set({ 'recommend': this.checked });
  });
  document.getElementById('mediaRecommend').addEventListener('change', function () {
    chrome.storage.sync.set({ 'mediaRecommend': this.checked });
  });
  document.getElementById('ad').addEventListener('change', function () {
    chrome.storage.sync.set({ 'ad': this.checked });
  });
  document.getElementById('fansTop').addEventListener('change', function () {
    chrome.storage.sync.set({ 'fansTop': this.checked });
  });
});
```

## Extension 3 step: Setup background.js

The `background.js` file separates storage logic from the content script (`main.js`). This allows for:

1. Cleaner separation of concerns
2. Asynchronous communication between scripts
3. Centralized, more efficient storage management
4. Easier maintenance and flexibility

```js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'getSettings') {
        chrome.storage.sync.get(['hotPush', 'recommend', 'mediaRecommend', 'ad', 'fansTop'], function (items) {
            sendResponse(items);
        });
        return true;
    }
});
```

## Extension 4 step: Make main.js

1. Callback and Async:
   - The `callback` function is asynchronous and uses the `await` keyword to call the `getSettings()` function.
   - This allows the code to wait for the settings to be retrieved from the background script before processing the DOM mutations.
2. MutationObserver:
   - The `MutationObserver` is used to monitor changes to the DOM structure of the web page.
   - When changes are detected, the `callback` function is called to process the mutations.
3. Config:
   - The `config` object defines the types of mutations the `MutationObserver` should watch for.
   - In this case, it's set to watch for changes to the child nodes (`childList: true`) and recursively observe the entire subtree (`subtree: true`).

```js
const getSettings = () => {
    return new Promise((resolve, reject) => {
        chrome.runtime.sendMessage({ action: 'getSettings' }, (response) => {
            if (chrome.runtime.lastError) {
                reject(chrome.runtime.lastError);
            } else {
                resolve(response);
            }
        });
    });
};

const callback = async (mutationsList, observer) => {
    try {
        const items = await getSettings();
        mutationsList.forEach(mutation => {
            if (mutation.type === 'childList') {
                const divs = document.querySelectorAll('#scroller > div.vue-recycle-scroller__item-wrapper > div');
                divs.forEach(function (div) {
                    const targetDiv = div.querySelector('div.wbpro-tag.wbpro-tag-c2.head-info_tag_3iMJw > div');
                    const targetContent = targetDiv ? targetDiv.textContent.trim() : '';
                    const isPromotedPost =
                        (items.hotPush && targetContent.match(/^(热推)$/))
                        || (items.recommend && targetContent.match(/^(推荐)$/))
                        || (items.mediaRecommend && targetContent.match(/^(媒体推荐)$/))
                        || (items.ad && div.querySelector('div[mark*="reallog_mark_ad"]') && !div.querySelector('div[mark*="999_reallog_mark_ad"]') && !targetContent.match(/^(热推)$/))
                        || (items.fansTop && (targetContent.match(/^(粉丝头条)$/) || div.querySelector('div[mark*="FansTop"]')));
                    const hasRepost = !!div.querySelector("div.Feed_retweet_JqZJb");
                    const displayValue = isPromotedPost ? 'none' : '';
                    if (hasRepost) {
                        div.querySelectorAll("div.wbpro-feed-content, div.Feed_retweet_JqZJb, footer").forEach(el => {
                            el.style.display = displayValue;
                        });
                    } else {
                        div.querySelectorAll("div.wbpro-feed-content, footer").forEach(el => {
                            el.style.display = displayValue;
                        });
                    }
                });
            }
        });
    } catch (error) {
        console.error('Failed to get settings:', error);
    }
};

const observer = new MutationObserver(callback);

const config = {
    childList: true,
    subtree: true
};

observer.observe(document, config);
console.log('Observer started');
```


