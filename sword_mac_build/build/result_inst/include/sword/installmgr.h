#ifndef INSTALLMGR_H
#define INSTALLMGR_H

#include <defs.h>
#include <swbuf.h>
#include <map>
#include <set>

SWORD_NAMESPACE_START

class SWMgr;
class SWModule;
class SWConfig;
class FTPTransport;
class StatusReporter;

/** TODO: document
*/
class SWDLLEXPORT InstallSource {
	SWMgr *mgr;
public:
	InstallSource(const char *type, const char *confEnt = 0);
	virtual ~InstallSource();
	SWBuf getConfEnt() {
		return caption +"|" + source + "|" + directory + "|" + u + "|" + p + "|" + uid;
	}
	SWBuf caption;
	SWBuf source;
	SWBuf directory;
	SWBuf u;
	SWBuf p;
	SWBuf uid;

	SWBuf type;
	SWBuf localShadow;
	void *userData;
	SWMgr *getMgr();
	void flush();
};

typedef std::map<SWBuf, InstallSource *> InstallSourceMap;

/** TODO: document
*/
class SWDLLEXPORT InstallMgr {

protected:
	bool userDisclaimerConfirmed;
	std::set<SWBuf> defaultMods;
	char *privatePath;
	SWBuf confPath;
	StatusReporter *statusReporter;
	bool passive;
	SWBuf u, p;
	
	// override this method and provide your own custom FTPTransport subclass
	virtual FTPTransport *createFTPTransport(const char *host, StatusReporter *statusReporter);

	// we have a transport member to set as current running transport so we
	// can ask it to terminate below, if user requests
	FTPTransport *transport;	
	
public:

	static const int MODSTAT_OLDER;
	static const int MODSTAT_SAMEVERSION;
	static const int MODSTAT_UPDATED;
	static const int MODSTAT_NEW;
	static const int MODSTAT_CIPHERED;
	static const int MODSTAT_CIPHERKEYPRESENT;

	SWConfig *installConf;
	InstallSourceMap sources;
	bool term;

	// Username and Password supplied here can be used to identify your frontend
	// by supplying a valid anon password like installmgr@macsword.com
	// This will get overridden if a password is required and provided in an indivual
	// source configuration
	InstallMgr(const char *privatePath = "./", StatusReporter *statusReporter = 0, SWBuf u="ftp", SWBuf p="installmgr@user.com");
	virtual ~InstallMgr();

	// Call to re-read InstallMgr.conf
	void readInstallConf();

	// Call to dump sources and other settings to InstallMgr.conf
	void saveInstallConf();

	// Removes all configured sources from memory.  Call saveInstallConf() to persist
	void clearSources();

	virtual int removeModule(SWMgr *manager, const char *modName);
	virtual int ftpCopy(InstallSource *is, const char *src, const char *dest, bool dirTransfer = false, const char *suffix = "");
	virtual int installModule(SWMgr *destMgr, const char *fromLocation, const char *modName, InstallSource *is = 0);
	
	virtual int refreshRemoteSource(InstallSource *is);
	virtual int refreshRemoteSourceConfiguration();
	/* user disclaimer should ask user for confirmation of 2 critical items:
	 * and the default answer should be NO
	 * (possible wrong language of disclaimer)
	 *
		cout << "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		cout << "                -=+* WARNING *+=- -=+* WARNING *+=-\n\n\n";
		cout << "Although Install Manager provides a convenient way for installing\n";
		cout << "and upgrading SWORD components, it also uses a systematic method\n";
		cout << "for accessing sites which gives packet sniffers a target to lock\n";
		cout << "into for singling out users. \n\n\n";
		cout << "IF YOU LIVE IN A PERSECUTED COUNTRY AND DO NOT WISH TO RISK DETECTION,\n";
		cout << "YOU SHOULD *NOT* USE INSTALL MANAGER'S REMOTE SOURCE FEATURES.\n\n\n";
		cout << "Also, Remote Sources other than CrossWire may contain less than\n";
		cout << "quality modules, module with unorthodox content, or even modules\n";
		cout << "which are not legitimately distributable.  Many repositories\n";
		cout << "contain wonderfully useful content.  These repositories simply\n";
		cout << "are not reviewed or maintained by CrossWire and CrossWire\n";
		cout << "cannot be held responsible for their content. CAVEAT EMPTOR.\n\n\n";
		cout << "If you understand this and are willing to enable remote source features\n";
		cout << "then type yes at the prompt\n\n";
		cout << "enable? [no] ";
	*/

	bool isUserDisclaimerConfirmed() const { return userDisclaimerConfirmed; }
	void setUserDisclaimerConfirmed(bool val) { userDisclaimerConfirmed = val; }
	virtual bool getCipherCode(const char *modName, SWConfig *config);
	void setFTPPassive(bool passive) { this->passive = passive; }
	bool isFTPPassive() { return passive; }
	void terminate();

	/************************************************************************
	 * getModuleStatus - compare the modules of two SWMgrs and return a 
	 * 	vector describing the status of each.  See MODSTAT_*
	 */
	static std::map<SWModule *, int> getModuleStatus(const SWMgr &base, const SWMgr &other);

	/************************************************************************
	 * isDefaultModule - allows an installation to provide a set of modules
	 *   in installMgr.conf like:
	 *     [General]
	 *     DefaultMod=KJV
	 *     DefaultMod=StrongsGreek
	 *     DefaultMod=Personal
	 *   This method allows a user interface to ask if a module is specified
	 *   as a default in the above way.  The logic is, if no modules are
	 *   installed then all default modules should be automatically selected for install
	 *   to help the user select a basic foundation of useful modules
	 */
	bool isDefaultModule(const char *modName);
};


SWORD_NAMESPACE_END

#endif
