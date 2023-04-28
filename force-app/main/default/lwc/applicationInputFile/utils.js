const MIME_LIST = [
	['jpeg', 'image/jpeg'],
	['jpg', 'image/jpeg'],
	['png', 'image/png'],
	['gif', 'image/gif'],
	['pdf', 'application/pdf']
];
const MIME_TYPE_MAP = new Map(MIME_LIST);

const fileTypesMap = (type) => {

     const map = new Map()
     map.set('mp3', 'audio')
     map.set('audio', 'audio')
     map.set('wav ', 'audio')
     map.set('csv', 'csv')
     map.set('eps', 'eps')
     map.set('xlsx', 'excel')
     map.set('xls', 'excel')
     map.set('xlsm', 'excel')
     map.set('xlsb', 'excel')
     map.set('xltx', 'excel')
     map.set('xml', 'xml')
     map.set('flash', 'flash')
     map.set('gdoc', 'gdoc')
     map.set('doc', 'gdoc')
     map.set('docx', 'gdoc')
     map.set('gform', 'gform')
     map.set('gdocs', 'gdocs')
     map.set('gpres', 'gpres')
     map.set('gsheet', 'gsheet')
     map.set('html', 'html')
     map.set('image', 'image')
     map.set('png', 'image')
     map.set('jpeg', 'image')
     map.set('jpg', 'image')
     map.set('svg', 'image')
     map.set('tif', 'image')
     map.set('tiff', 'image')
     map.set('webp', 'image')
     map.set('mp4', 'mp4')
     map.set('mk4', 'mp4')
     map.set('mkv', 'mp4')
     map.set('pdf', 'pdf')
     map.set('ppt', 'ppt')
     map.set('psd', 'psd')
     map.set('quip_doc', 'quip_doc')
     map.set('quip_sheet', 'quip_sheet')
     map.set('quip_slide', 'quip_slide')
     map.set('rtf', 'rtf')
     map.set('slide', 'slide')
     map.set('pptx', 'slide')
     map.set('ppt', 'slide')
     map.set('video', 'video')
     map.set('mov', 'video')
     map.set('gif', 'video')
     map.set('visio', 'visio')
     map.set('word', 'word')
     map.set('zip', 'zip')
     map.set('rar ', 'zip')
     map.set('txt', 'txt')
     return map.get(type)
}


function getMimeTypeFromExtension(extension) {
	return MIME_TYPE_MAP.get(extension);
}

export { fileTypesMap, getMimeTypeFromExtension }