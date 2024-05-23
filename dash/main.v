import encoding.xml
import flag
import os

// MPD 파일의 내용을 파싱하는 함수
fn parse_mpd(mpd_content string) {
	// XML 파싱
	document := xml.XMLDocument.from_string(mpd_content) or {
		eprintln('Failed to parse XML: ${err}')
		return
	}

	// Root element 추출 (여기서는 "MPD")
	mpd_node := document.root

	// "Period" 태그 찾기
	for child in mpd_node.children {
		match child {
			xml.XMLNode {
				if child.name == 'Period' {
					println('Found a Period')
					for adaptation_set in child.children {
						match adaptation_set {
							xml.XMLNode {
								if adaptation_set.name == 'AdaptationSet' {
									println('Found an AdaptationSet')
									for representation in adaptation_set.children {
										match representation {
											xml.XMLNode {
												if representation.name == 'Representation' {
													mime_type := representation.attributes['id'] or {
														'unknown'
													}
													codecs := representation.attributes['bandwidth'] or {
														'unknown'
													}
													println('Found an Representation -> mimeType: ${mime_type}, codecs: ${codecs}')
												}
											}
											else {
												// skip
											}
										}
									}
								}
							}
							else {
								// skip
							}
						}
					}
				}
			}
			else {
				// skip
			}
		}
		// if child.name == 'Period' {
		// 	println('Found a Period element')
		// 	// "AdaptationSet" 태그 찾기
		// 	for adaptation_set in child.children {
		// 		if adaptation_set.name == 'AdaptationSet' {
		// 			println('Found an AdaptationSet element')
		// 			// 각 AdaptationSet에서 "Representation" 정보 추출
		// 			for representation in adaptation_set.children {
		// 				if representation.name == 'Representation' {
		// 					mime_type := representation.attrs['mimeType'] or { 'unknown' }
		// 					codecs := representation.attrs['codecs'] or { 'unknown' }
		// 					println('Representation mimeType: $mime_type, codecs: $codecs')
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
}

// MPD 파일을 로드하고 파싱하는 메인 함수
fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('MPD File Parser')
	fp.version('1.0')
	fp.description('Parses DASH MPD files to extract stream information.')

	file_path := fp.string('file', `f`, '', 'Path to the MPD file to parse')
	if file_path == '' {
		println('Please provide a file path using -file or -f.')
		return
	}
	// MPD 파일 로드
	mpd_content := os.read_file(file_path) or {
		eprintln('Failed to read MPD file: ${err}')
		return
	}

	// 파싱 함수 호출
	parse_mpd(mpd_content)
}
