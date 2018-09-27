#Spdr Srch: flexible find-and-replace form using Perl

I wrote this tool when working with a site system where I could execute Perl but not access SSH. This reproduced many of the advanced search operations typically handled with grep and avoided the need to manually update links and boilerplate code in hundreds of files scattered across various nested directories.

The tool consists of an HTML form (spdrsrch.htm - currently relies on manually entered directory paths), an executable that performs the search and displays results (spdrsrch.plx) and a few utility functions (spdrUtils.pm).
