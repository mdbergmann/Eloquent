/******************************************************************************
 *
 *  url.h -	code for an URL parser utility class
 *
 * $Id: url.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2004-2013 CrossWire Bible Society (http://www.crosswire.org)
 *	CrossWire Bible Society
 *	P. O. Box 2528
 *	Tempe, AZ  85280-2528
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation version 2.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 */

#ifndef URL_H
#define URL_H

#include <swbuf.h>
#include <map>

SWORD_NAMESPACE_START

/** URL provides URL parsing
 * The URL class provides an interface to work on the data of an URL like "http://www.crosswire.org/index.jsp?page=test&amp;user=nobody"
 */
class SWDLLEXPORT URL {
public:
	typedef std::map<SWBuf, SWBuf> ParameterMap;
	
	/** Constructor.
	 * @param url The url string which should be parsed into protocol, hostname, path and paramters
	 */
	URL(const char *url);
	
	/** Get the protocol.
	* @return The protocol, e.g. "http" for an url like "http://www.crosswire.org/index.jsp?page=help"
	*/
	const char *getProtocol() const;
	/** Get the hostname
	* @return The hostname, e.g. "www.crosswire.org" for an url like "http://www.crosswire.org/index.jsp?page=help"
	*/
	const char *getHostName() const;
	/** Get the path
	* @return The path, e.g. "/index.jsp" for an url like "http://www.crosswire.org/index.jsp?page=help"
	*/
	const char *getPath() const;
	
	/** All available paramters
	* @return The map which contains the parameters and their values
	*/
	const ParameterMap &getParameters() const;
	
	/**
	 * Returns the value of an URL parameter. For the URL "http://www.crosswire.org/index.jsp?page=test&amp;user=nobody" the value of the parameter "page" would be "test".
	 * If the parameter is not set an empty string is returned.
	 * @param name The name of the paramter.
	 * @return The value of the given paramter of an empty string if the name could not be found in the list of available paramters
	 */
	const char *getParameterValue(const char *name) const;
	
	/** Encodes and URL
	* Encodes a string into a valid URL, e.g. changes http://www.crosswire.org/test.jsp?force=1&help=1 into
	* http://www.crosswire.org/test.jsp?force=1&amp;help=1
	* This function works on the data of the buf parameter.
	*
	* WARNING: It doesn't check if the URL is encoded already, so http://www.crosswire.org/test.jsp?force=1&amp;help=1 becomes http://www.crosswire.org/test.jsp?force=1&amp;amp;help=1
	*/
	static const SWBuf encode(const char *urlText);	
	static const SWBuf decode(const char *encodedText);
	
private:
	/** Parse
	 * Parse the URL into protocol, hostname, path, page and paramters
	 */
	void parse();
		
	SWBuf url;
	SWBuf protocol;
	SWBuf hostname;
	SWBuf path;
	ParameterMap parameterMap;
};

SWORD_NAMESPACE_END

#endif //URL_H
