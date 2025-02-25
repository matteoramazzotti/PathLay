
export function getQueryParam(param,url) {
	const urlObj = url ? new URL(url) : window.location;
	const urlParams = new URLSearchParams(urlObj.search);
	return urlParams.get(param);
}