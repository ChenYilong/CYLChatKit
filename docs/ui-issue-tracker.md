# UI Issue Fix Tracker

Tracking 301 issues: 295 from `leancloud/ChatKit-OC` and 6 from `ChenYilong/CYLChatKit`.
UI assessment: 151 UI-related issues; evidence-based average progress **5%** (825/15100 points).
The source snapshot merge is recorded in [commit 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6).

## Assessment rules

- Scores measure verified completion in this target repository, not the upstream GitHub issue state. A closed issue is not counted as fixed without matching code or a fix commit.
- Non-UI issues remain listed and are marked `N/A` because this task is limited to UI work.
- UI scope is screened for explicit user-visible rendering, layout, or interaction behavior in the issue title and description; ambiguous reports without that evidence are marked out of scope.
- `100%` requires an issue-specific fix commit identified in repository history. `75%` means related implementation is merged but the reported behavior still needs runtime verification. `0%` means unresolved or not verifiably fixed.
- Issue IDs and canonical HTTPS links are used so repository-authored tracker text stays English. Missing fix-commit links mean no matching fix commit was verified.
| Issue | Fix commit | Assessment |
|---|---|---|
| [ChenYilong/CYLChatKit #6 (open)](https://github.com/ChenYilong/CYLChatKit/issues/6) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Image sizing code is present in the merge; unknown-dimension behavior is not runtime-verified. Score: 75%. |
| [ChenYilong/CYLChatKit #5 (open)](https://github.com/ChenYilong/CYLChatKit/issues/5) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [ChenYilong/CYLChatKit #4 (open)](https://github.com/ChenYilong/CYLChatKit/issues/4) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Avatar sizing code is present in the merge; device-size behavior is not runtime-verified. Score: 75%. |
| [ChenYilong/CYLChatKit #3 (open)](https://github.com/ChenYilong/CYLChatKit/issues/3) | — | Recording cancellation still lacks TouchCancel handling, so an interrupted recording is not fixed. Score: 0%. |
| [ChenYilong/CYLChatKit #2 (open)](https://github.com/ChenYilong/CYLChatKit/issues/2) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [ChenYilong/CYLChatKit #1 (open)](https://github.com/ChenYilong/CYLChatKit/issues/1) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #430 (open)](https://github.com/leancloud/ChatKit-OC/issues/430) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #429 (open)](https://github.com/leancloud/ChatKit-OC/issues/429) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #428 (open)](https://github.com/leancloud/ChatKit-OC/issues/428) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #427 (open)](https://github.com/leancloud/ChatKit-OC/issues/427) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #423 (open)](https://github.com/leancloud/ChatKit-OC/issues/423) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #422 (open)](https://github.com/leancloud/ChatKit-OC/issues/422) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #421 (open)](https://github.com/leancloud/ChatKit-OC/issues/421) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #420 (open)](https://github.com/leancloud/ChatKit-OC/issues/420) | — | Overlay-window/key-window restoration remains unverified and the existing ordering can prevent correct restoration. Score: 0%. |
| [leancloud/ChatKit-OC #418 (open)](https://github.com/leancloud/ChatKit-OC/issues/418) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #417 (open)](https://github.com/leancloud/ChatKit-OC/issues/417) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #414 (open)](https://github.com/leancloud/ChatKit-OC/issues/414) | — | The HUD countdown still lacks a verified timeout dismissal; the negative/continuing timer report remains open. Score: 0%. |
| [leancloud/ChatKit-OC #413 (open)](https://github.com/leancloud/ChatKit-OC/issues/413) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #405 (open)](https://github.com/leancloud/ChatKit-OC/issues/405) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #402 (open)](https://github.com/leancloud/ChatKit-OC/issues/402) | — | Failed text-message rendering has not been verified end to end. Score: 0%. |
| [leancloud/ChatKit-OC #401 (closed)](https://github.com/leancloud/ChatKit-OC/issues/401) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #400 (open)](https://github.com/leancloud/ChatKit-OC/issues/400) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #398 (closed)](https://github.com/leancloud/ChatKit-OC/issues/398) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #397 (closed)](https://github.com/leancloud/ChatKit-OC/issues/397) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #392 (closed)](https://github.com/leancloud/ChatKit-OC/issues/392) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #390 (open)](https://github.com/leancloud/ChatKit-OC/issues/390) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #389 (closed)](https://github.com/leancloud/ChatKit-OC/issues/389) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #387 (closed)](https://github.com/leancloud/ChatKit-OC/issues/387) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #386 (open)](https://github.com/leancloud/ChatKit-OC/issues/386) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #385 (open)](https://github.com/leancloud/ChatKit-OC/issues/385) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Conversation-list avatar handling is present in the merge; the reported flicker is not runtime-verified. Score: 75%. |
| [leancloud/ChatKit-OC #384 (open)](https://github.com/leancloud/ChatKit-OC/issues/384) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #383 (open)](https://github.com/leancloud/ChatKit-OC/issues/383) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #382 (open)](https://github.com/leancloud/ChatKit-OC/issues/382) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #381 (open)](https://github.com/leancloud/ChatKit-OC/issues/381) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #375 (open)](https://github.com/leancloud/ChatKit-OC/issues/375) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #371 (open)](https://github.com/leancloud/ChatKit-OC/issues/371) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #370 (open)](https://github.com/leancloud/ChatKit-OC/issues/370) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #369 (open)](https://github.com/leancloud/ChatKit-OC/issues/369) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #367 (open)](https://github.com/leancloud/ChatKit-OC/issues/367) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #364 (open)](https://github.com/leancloud/ChatKit-OC/issues/364) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #362 (open)](https://github.com/leancloud/ChatKit-OC/issues/362) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #361 (open)](https://github.com/leancloud/ChatKit-OC/issues/361) | — | iPhone X safe-area behavior has not been verified against the reported layout. Score: 0%. |
| [leancloud/ChatKit-OC #360 (open)](https://github.com/leancloud/ChatKit-OC/issues/360) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #356 (open)](https://github.com/leancloud/ChatKit-OC/issues/356) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #354 (open)](https://github.com/leancloud/ChatKit-OC/issues/354) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #353 (closed)](https://github.com/leancloud/ChatKit-OC/issues/353) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #351 (open)](https://github.com/leancloud/ChatKit-OC/issues/351) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #350 (closed)](https://github.com/leancloud/ChatKit-OC/issues/350) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #349 (open)](https://github.com/leancloud/ChatKit-OC/issues/349) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #348 (open)](https://github.com/leancloud/ChatKit-OC/issues/348) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Conversation avatar frame/corner handling is present in the merge; visual behavior is not runtime-verified. Score: 75%. |
| [leancloud/ChatKit-OC #347 (open)](https://github.com/leancloud/ChatKit-OC/issues/347) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Avatar frame/corner handling is present in the merge; visual behavior is not runtime-verified. Score: 75%. |
| [leancloud/ChatKit-OC #346 (open)](https://github.com/leancloud/ChatKit-OC/issues/346) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #345 (open)](https://github.com/leancloud/ChatKit-OC/issues/345) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #344 (closed)](https://github.com/leancloud/ChatKit-OC/issues/344) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #343 (open)](https://github.com/leancloud/ChatKit-OC/issues/343) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #342 (open)](https://github.com/leancloud/ChatKit-OC/issues/342) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #341 (open)](https://github.com/leancloud/ChatKit-OC/issues/341) | — | The short-text bubble-width report has not been verified end to end. Score: 0%. |
| [leancloud/ChatKit-OC #340 (closed)](https://github.com/leancloud/ChatKit-OC/issues/340) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #339 (open)](https://github.com/leancloud/ChatKit-OC/issues/339) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #338 (closed)](https://github.com/leancloud/ChatKit-OC/issues/338) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #337 (closed)](https://github.com/leancloud/ChatKit-OC/issues/337) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #336 (closed)](https://github.com/leancloud/ChatKit-OC/issues/336) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #335 (closed)](https://github.com/leancloud/ChatKit-OC/issues/335) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #333 (closed)](https://github.com/leancloud/ChatKit-OC/issues/333) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #332 (closed)](https://github.com/leancloud/ChatKit-OC/issues/332) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #331 (closed)](https://github.com/leancloud/ChatKit-OC/issues/331) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #330 (open)](https://github.com/leancloud/ChatKit-OC/issues/330) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #329 (open)](https://github.com/leancloud/ChatKit-OC/issues/329) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #328 (open)](https://github.com/leancloud/ChatKit-OC/issues/328) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #327 (open)](https://github.com/leancloud/ChatKit-OC/issues/327) | — | No verified fix for the disappearing image-selection button is present in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #326 (open)](https://github.com/leancloud/ChatKit-OC/issues/326) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #325 (open)](https://github.com/leancloud/ChatKit-OC/issues/325) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #324 (closed)](https://github.com/leancloud/ChatKit-OC/issues/324) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #322 (open)](https://github.com/leancloud/ChatKit-OC/issues/322) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #321 (open)](https://github.com/leancloud/ChatKit-OC/issues/321) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #320 (open)](https://github.com/leancloud/ChatKit-OC/issues/320) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #319 (open)](https://github.com/leancloud/ChatKit-OC/issues/319) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #318 (open)](https://github.com/leancloud/ChatKit-OC/issues/318) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #317 (open)](https://github.com/leancloud/ChatKit-OC/issues/317) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #315 (open)](https://github.com/leancloud/ChatKit-OC/issues/315) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #314 (open)](https://github.com/leancloud/ChatKit-OC/issues/314) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #313 (open)](https://github.com/leancloud/ChatKit-OC/issues/313) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #312 (open)](https://github.com/leancloud/ChatKit-OC/issues/312) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #311 (closed)](https://github.com/leancloud/ChatKit-OC/issues/311) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #310 (open)](https://github.com/leancloud/ChatKit-OC/issues/310) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #309 (closed)](https://github.com/leancloud/ChatKit-OC/issues/309) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #308 (open)](https://github.com/leancloud/ChatKit-OC/issues/308) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #307 (open)](https://github.com/leancloud/ChatKit-OC/issues/307) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #306 (open)](https://github.com/leancloud/ChatKit-OC/issues/306) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #305 (open)](https://github.com/leancloud/ChatKit-OC/issues/305) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #304 (closed)](https://github.com/leancloud/ChatKit-OC/issues/304) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #302 (open)](https://github.com/leancloud/ChatKit-OC/issues/302) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #301 (open)](https://github.com/leancloud/ChatKit-OC/issues/301) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #300 (closed)](https://github.com/leancloud/ChatKit-OC/issues/300) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #299 (closed)](https://github.com/leancloud/ChatKit-OC/issues/299) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #298 (open)](https://github.com/leancloud/ChatKit-OC/issues/298) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #297 (closed)](https://github.com/leancloud/ChatKit-OC/issues/297) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #296 (open)](https://github.com/leancloud/ChatKit-OC/issues/296) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #295 (open)](https://github.com/leancloud/ChatKit-OC/issues/295) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #294 (open)](https://github.com/leancloud/ChatKit-OC/issues/294) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #293 (closed)](https://github.com/leancloud/ChatKit-OC/issues/293) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #292 (open)](https://github.com/leancloud/ChatKit-OC/issues/292) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #291 (open)](https://github.com/leancloud/ChatKit-OC/issues/291) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #290 (open)](https://github.com/leancloud/ChatKit-OC/issues/290) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #289 (open)](https://github.com/leancloud/ChatKit-OC/issues/289) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #288 (closed)](https://github.com/leancloud/ChatKit-OC/issues/288) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #287 (closed)](https://github.com/leancloud/ChatKit-OC/issues/287) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #286 (open)](https://github.com/leancloud/ChatKit-OC/issues/286) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #285 (closed)](https://github.com/leancloud/ChatKit-OC/issues/285) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #283 (open)](https://github.com/leancloud/ChatKit-OC/issues/283) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #282 (open)](https://github.com/leancloud/ChatKit-OC/issues/282) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #281 (open)](https://github.com/leancloud/ChatKit-OC/issues/281) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #280 (open)](https://github.com/leancloud/ChatKit-OC/issues/280) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #279 (open)](https://github.com/leancloud/ChatKit-OC/issues/279) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Image-cell sizing logic is present in the merge; the reported oversized-cell case needs reproduction. Score: 75%. |
| [leancloud/ChatKit-OC #276 (closed)](https://github.com/leancloud/ChatKit-OC/issues/276) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #275 (open)](https://github.com/leancloud/ChatKit-OC/issues/275) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #274 (open)](https://github.com/leancloud/ChatKit-OC/issues/274) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #273 (closed)](https://github.com/leancloud/ChatKit-OC/issues/273) | [commit 5c44e1321111](https://github.com/ChenYilong/CYLChatKit/commit/5c44e1321111a4c424a40b6338b73b877f4a4ec0) | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #271 (open)](https://github.com/leancloud/ChatKit-OC/issues/271) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #270 (open)](https://github.com/leancloud/ChatKit-OC/issues/270) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #269 (open)](https://github.com/leancloud/ChatKit-OC/issues/269) | — | The microphone permission callback still returns before the asynchronous permission result is known. Score: 0%. |
| [leancloud/ChatKit-OC #268 (closed)](https://github.com/leancloud/ChatKit-OC/issues/268) | [commit 250c131d5777](https://github.com/ChenYilong/CYLChatKit/commit/250c131d5777ab5be42f60dc4dfb92fb753c55fe) | Verified issue-specific fix commit in repository history (100%). |
| [leancloud/ChatKit-OC #267 (closed)](https://github.com/leancloud/ChatKit-OC/issues/267) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #266 (open)](https://github.com/leancloud/ChatKit-OC/issues/266) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #265 (closed)](https://github.com/leancloud/ChatKit-OC/issues/265) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #264 (open)](https://github.com/leancloud/ChatKit-OC/issues/264) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #262 (closed)](https://github.com/leancloud/ChatKit-OC/issues/262) | [commit 12832692e7bd](https://github.com/ChenYilong/CYLChatKit/commit/12832692e7bd60a9d8cd27f9f9661bb29daae88b) | Verified issue-specific fix commit in repository history (100%). |
| [leancloud/ChatKit-OC #261 (open)](https://github.com/leancloud/ChatKit-OC/issues/261) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #260 (closed)](https://github.com/leancloud/ChatKit-OC/issues/260) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #259 (closed)](https://github.com/leancloud/ChatKit-OC/issues/259) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #258 (open)](https://github.com/leancloud/ChatKit-OC/issues/258) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #257 (closed)](https://github.com/leancloud/ChatKit-OC/issues/257) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #256 (closed)](https://github.com/leancloud/ChatKit-OC/issues/256) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #255 (open)](https://github.com/leancloud/ChatKit-OC/issues/255) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #254 (closed)](https://github.com/leancloud/ChatKit-OC/issues/254) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #253 (closed)](https://github.com/leancloud/ChatKit-OC/issues/253) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #252 (closed)](https://github.com/leancloud/ChatKit-OC/issues/252) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #251 (open)](https://github.com/leancloud/ChatKit-OC/issues/251) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #250 (closed)](https://github.com/leancloud/ChatKit-OC/issues/250) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #249 (closed)](https://github.com/leancloud/ChatKit-OC/issues/249) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #248 (open)](https://github.com/leancloud/ChatKit-OC/issues/248) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #247 (closed)](https://github.com/leancloud/ChatKit-OC/issues/247) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #246 (open)](https://github.com/leancloud/ChatKit-OC/issues/246) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #245 (closed)](https://github.com/leancloud/ChatKit-OC/issues/245) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #244 (open)](https://github.com/leancloud/ChatKit-OC/issues/244) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #243 (closed)](https://github.com/leancloud/ChatKit-OC/issues/243) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #242 (closed)](https://github.com/leancloud/ChatKit-OC/issues/242) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #241 (closed)](https://github.com/leancloud/ChatKit-OC/issues/241) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #237 (closed)](https://github.com/leancloud/ChatKit-OC/issues/237) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #236 (closed)](https://github.com/leancloud/ChatKit-OC/issues/236) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #235 (open)](https://github.com/leancloud/ChatKit-OC/issues/235) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #231 (closed)](https://github.com/leancloud/ChatKit-OC/issues/231) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #230 (closed)](https://github.com/leancloud/ChatKit-OC/issues/230) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #228 (closed)](https://github.com/leancloud/ChatKit-OC/issues/228) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #227 (closed)](https://github.com/leancloud/ChatKit-OC/issues/227) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #226 (closed)](https://github.com/leancloud/ChatKit-OC/issues/226) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #225 (closed)](https://github.com/leancloud/ChatKit-OC/issues/225) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #223 (closed)](https://github.com/leancloud/ChatKit-OC/issues/223) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #221 (open)](https://github.com/leancloud/ChatKit-OC/issues/221) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #220 (closed)](https://github.com/leancloud/ChatKit-OC/issues/220) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #219 (closed)](https://github.com/leancloud/ChatKit-OC/issues/219) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #218 (open)](https://github.com/leancloud/ChatKit-OC/issues/218) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #217 (closed)](https://github.com/leancloud/ChatKit-OC/issues/217) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #216 (open)](https://github.com/leancloud/ChatKit-OC/issues/216) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #215 (closed)](https://github.com/leancloud/ChatKit-OC/issues/215) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #214 (closed)](https://github.com/leancloud/ChatKit-OC/issues/214) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #213 (closed)](https://github.com/leancloud/ChatKit-OC/issues/213) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #209 (closed)](https://github.com/leancloud/ChatKit-OC/issues/209) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #204 (closed)](https://github.com/leancloud/ChatKit-OC/issues/204) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #202 (open)](https://github.com/leancloud/ChatKit-OC/issues/202) | [merge 90e4409b504c](https://github.com/ChenYilong/CYLChatKit/commit/90e4409b504ccfed2285b4a7e023ec0cef2054c6) | Navigation-title layout code is present in the merge; initial placement still needs UI reproduction. Score: 75%. |
| [leancloud/ChatKit-OC #199 (open)](https://github.com/leancloud/ChatKit-OC/issues/199) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #198 (open)](https://github.com/leancloud/ChatKit-OC/issues/198) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #194 (open)](https://github.com/leancloud/ChatKit-OC/issues/194) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #193 (open)](https://github.com/leancloud/ChatKit-OC/issues/193) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #190 (open)](https://github.com/leancloud/ChatKit-OC/issues/190) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #189 (open)](https://github.com/leancloud/ChatKit-OC/issues/189) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #188 (open)](https://github.com/leancloud/ChatKit-OC/issues/188) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #187 (closed)](https://github.com/leancloud/ChatKit-OC/issues/187) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #186 (open)](https://github.com/leancloud/ChatKit-OC/issues/186) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #185 (open)](https://github.com/leancloud/ChatKit-OC/issues/185) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #179 (closed)](https://github.com/leancloud/ChatKit-OC/issues/179) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #178 (closed)](https://github.com/leancloud/ChatKit-OC/issues/178) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #177 (closed)](https://github.com/leancloud/ChatKit-OC/issues/177) | [commit 14b35f5d1fe6](https://github.com/ChenYilong/CYLChatKit/commit/14b35f5d1fe6821f9dbecf3d100956b7c0426a89) | Verified issue-specific fix commit in repository history (100%). |
| [leancloud/ChatKit-OC #166 (closed)](https://github.com/leancloud/ChatKit-OC/issues/166) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #164 (closed)](https://github.com/leancloud/ChatKit-OC/issues/164) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #163 (open)](https://github.com/leancloud/ChatKit-OC/issues/163) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #161 (closed)](https://github.com/leancloud/ChatKit-OC/issues/161) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #159 (open)](https://github.com/leancloud/ChatKit-OC/issues/159) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #158 (closed)](https://github.com/leancloud/ChatKit-OC/issues/158) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #156 (open)](https://github.com/leancloud/ChatKit-OC/issues/156) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #155 (closed)](https://github.com/leancloud/ChatKit-OC/issues/155) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #153 (closed)](https://github.com/leancloud/ChatKit-OC/issues/153) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #150 (open)](https://github.com/leancloud/ChatKit-OC/issues/150) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #149 (closed)](https://github.com/leancloud/ChatKit-OC/issues/149) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #146 (closed)](https://github.com/leancloud/ChatKit-OC/issues/146) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #144 (closed)](https://github.com/leancloud/ChatKit-OC/issues/144) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #143 (closed)](https://github.com/leancloud/ChatKit-OC/issues/143) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #141 (open)](https://github.com/leancloud/ChatKit-OC/issues/141) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #139 (open)](https://github.com/leancloud/ChatKit-OC/issues/139) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #137 (closed)](https://github.com/leancloud/ChatKit-OC/issues/137) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #133 (open)](https://github.com/leancloud/ChatKit-OC/issues/133) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #131 (closed)](https://github.com/leancloud/ChatKit-OC/issues/131) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #130 (closed)](https://github.com/leancloud/ChatKit-OC/issues/130) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #129 (open)](https://github.com/leancloud/ChatKit-OC/issues/129) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #128 (open)](https://github.com/leancloud/ChatKit-OC/issues/128) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #127 (open)](https://github.com/leancloud/ChatKit-OC/issues/127) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #125 (open)](https://github.com/leancloud/ChatKit-OC/issues/125) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #124 (open)](https://github.com/leancloud/ChatKit-OC/issues/124) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #123 (open)](https://github.com/leancloud/ChatKit-OC/issues/123) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #122 (open)](https://github.com/leancloud/ChatKit-OC/issues/122) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #121 (open)](https://github.com/leancloud/ChatKit-OC/issues/121) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #120 (closed)](https://github.com/leancloud/ChatKit-OC/issues/120) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #119 (closed)](https://github.com/leancloud/ChatKit-OC/issues/119) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #118 (closed)](https://github.com/leancloud/ChatKit-OC/issues/118) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #117 (closed)](https://github.com/leancloud/ChatKit-OC/issues/117) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #114 (closed)](https://github.com/leancloud/ChatKit-OC/issues/114) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #109 (open)](https://github.com/leancloud/ChatKit-OC/issues/109) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #108 (open)](https://github.com/leancloud/ChatKit-OC/issues/108) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #107 (open)](https://github.com/leancloud/ChatKit-OC/issues/107) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #105 (closed)](https://github.com/leancloud/ChatKit-OC/issues/105) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #102 (open)](https://github.com/leancloud/ChatKit-OC/issues/102) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #100 (closed)](https://github.com/leancloud/ChatKit-OC/issues/100) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #99 (closed)](https://github.com/leancloud/ChatKit-OC/issues/99) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #98 (closed)](https://github.com/leancloud/ChatKit-OC/issues/98) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #97 (open)](https://github.com/leancloud/ChatKit-OC/issues/97) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #96 (open)](https://github.com/leancloud/ChatKit-OC/issues/96) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #95 (closed)](https://github.com/leancloud/ChatKit-OC/issues/95) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #94 (closed)](https://github.com/leancloud/ChatKit-OC/issues/94) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #93 (closed)](https://github.com/leancloud/ChatKit-OC/issues/93) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #92 (closed)](https://github.com/leancloud/ChatKit-OC/issues/92) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #91 (closed)](https://github.com/leancloud/ChatKit-OC/issues/91) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #84 (closed)](https://github.com/leancloud/ChatKit-OC/issues/84) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #83 (closed)](https://github.com/leancloud/ChatKit-OC/issues/83) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #82 (closed)](https://github.com/leancloud/ChatKit-OC/issues/82) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #81 (closed)](https://github.com/leancloud/ChatKit-OC/issues/81) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #80 (closed)](https://github.com/leancloud/ChatKit-OC/issues/80) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #79 (closed)](https://github.com/leancloud/ChatKit-OC/issues/79) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #78 (closed)](https://github.com/leancloud/ChatKit-OC/issues/78) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #77 (closed)](https://github.com/leancloud/ChatKit-OC/issues/77) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #76 (closed)](https://github.com/leancloud/ChatKit-OC/issues/76) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #75 (closed)](https://github.com/leancloud/ChatKit-OC/issues/75) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #74 (closed)](https://github.com/leancloud/ChatKit-OC/issues/74) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #73 (closed)](https://github.com/leancloud/ChatKit-OC/issues/73) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #72 (closed)](https://github.com/leancloud/ChatKit-OC/issues/72) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #70 (open)](https://github.com/leancloud/ChatKit-OC/issues/70) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #69 (open)](https://github.com/leancloud/ChatKit-OC/issues/69) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #68 (closed)](https://github.com/leancloud/ChatKit-OC/issues/68) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #66 (closed)](https://github.com/leancloud/ChatKit-OC/issues/66) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #65 (closed)](https://github.com/leancloud/ChatKit-OC/issues/65) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #64 (closed)](https://github.com/leancloud/ChatKit-OC/issues/64) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #63 (closed)](https://github.com/leancloud/ChatKit-OC/issues/63) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #62 (open)](https://github.com/leancloud/ChatKit-OC/issues/62) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #61 (closed)](https://github.com/leancloud/ChatKit-OC/issues/61) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #60 (open)](https://github.com/leancloud/ChatKit-OC/issues/60) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #59 (open)](https://github.com/leancloud/ChatKit-OC/issues/59) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #58 (closed)](https://github.com/leancloud/ChatKit-OC/issues/58) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #57 (open)](https://github.com/leancloud/ChatKit-OC/issues/57) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #56 (closed)](https://github.com/leancloud/ChatKit-OC/issues/56) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #55 (closed)](https://github.com/leancloud/ChatKit-OC/issues/55) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #54 (closed)](https://github.com/leancloud/ChatKit-OC/issues/54) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #53 (closed)](https://github.com/leancloud/ChatKit-OC/issues/53) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #52 (closed)](https://github.com/leancloud/ChatKit-OC/issues/52) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #51 (closed)](https://github.com/leancloud/ChatKit-OC/issues/51) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #50 (closed)](https://github.com/leancloud/ChatKit-OC/issues/50) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #49 (closed)](https://github.com/leancloud/ChatKit-OC/issues/49) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #48 (closed)](https://github.com/leancloud/ChatKit-OC/issues/48) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #47 (closed)](https://github.com/leancloud/ChatKit-OC/issues/47) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #46 (open)](https://github.com/leancloud/ChatKit-OC/issues/46) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #45 (closed)](https://github.com/leancloud/ChatKit-OC/issues/45) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #44 (closed)](https://github.com/leancloud/ChatKit-OC/issues/44) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #43 (open)](https://github.com/leancloud/ChatKit-OC/issues/43) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #42 (closed)](https://github.com/leancloud/ChatKit-OC/issues/42) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #41 (closed)](https://github.com/leancloud/ChatKit-OC/issues/41) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #40 (open)](https://github.com/leancloud/ChatKit-OC/issues/40) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #39 (closed)](https://github.com/leancloud/ChatKit-OC/issues/39) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #38 (closed)](https://github.com/leancloud/ChatKit-OC/issues/38) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #37 (open)](https://github.com/leancloud/ChatKit-OC/issues/37) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #36 (closed)](https://github.com/leancloud/ChatKit-OC/issues/36) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #35 (closed)](https://github.com/leancloud/ChatKit-OC/issues/35) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #34 (closed)](https://github.com/leancloud/ChatKit-OC/issues/34) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #33 (closed)](https://github.com/leancloud/ChatKit-OC/issues/33) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #32 (closed)](https://github.com/leancloud/ChatKit-OC/issues/32) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #31 (closed)](https://github.com/leancloud/ChatKit-OC/issues/31) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #30 (closed)](https://github.com/leancloud/ChatKit-OC/issues/30) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #29 (open)](https://github.com/leancloud/ChatKit-OC/issues/29) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #28 (open)](https://github.com/leancloud/ChatKit-OC/issues/28) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #27 (closed)](https://github.com/leancloud/ChatKit-OC/issues/27) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #26 (closed)](https://github.com/leancloud/ChatKit-OC/issues/26) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #25 (closed)](https://github.com/leancloud/ChatKit-OC/issues/25) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #24 (closed)](https://github.com/leancloud/ChatKit-OC/issues/24) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #23 (open)](https://github.com/leancloud/ChatKit-OC/issues/23) | — | No issue-specific fix commit or verified implementation was identified in this merge. Score: 0%. |
| [leancloud/ChatKit-OC #20 (closed)](https://github.com/leancloud/ChatKit-OC/issues/20) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #19 (closed)](https://github.com/leancloud/ChatKit-OC/issues/19) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #18 (closed)](https://github.com/leancloud/ChatKit-OC/issues/18) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #17 (closed)](https://github.com/leancloud/ChatKit-OC/issues/17) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #15 (open)](https://github.com/leancloud/ChatKit-OC/issues/15) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #14 (closed)](https://github.com/leancloud/ChatKit-OC/issues/14) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
| [leancloud/ChatKit-OC #13 (closed)](https://github.com/leancloud/ChatKit-OC/issues/13) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #12 (closed)](https://github.com/leancloud/ChatKit-OC/issues/12) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #3 (closed)](https://github.com/leancloud/ChatKit-OC/issues/3) | — | Not UI-related; no fix required under this UI-only scope (N/A). |
| [leancloud/ChatKit-OC #1 (closed)](https://github.com/leancloud/ChatKit-OC/issues/1) | — | Upstream is closed, but no matching fix commit or implementation was verified in this target repository. Score: 0%. |
