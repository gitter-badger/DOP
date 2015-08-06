package ee.hm.dop.oaipmh;

import static ee.hm.dop.utils.DateUtils.toJson;

import java.util.Iterator;

import org.joda.time.DateTime;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import ORG.oclc.oai.harvester2.verb.ListIdentifiers;

public class ListIdentifiersConnector {

    String resumptionToken;
    private NodeList headers;
    private String baseURL;

    public ListIdentifiersConnector connect(String baseURL, DateTime from, String metadataPrefix) throws Exception {
        ListIdentifiers listIdentifiers = newListIdentifier(baseURL, from, metadataPrefix);
        headers = getHeaders(listIdentifiers);
        resumptionToken = listIdentifiers.getResumptionToken();
        this.baseURL = baseURL;
        return this;
    }

    public Iterator<Element> iterator() throws Exception {
        return new IdentifierIterator(headers, baseURL, resumptionToken);
    }

    protected ListIdentifiers newListIdentifier(String baseURL, DateTime from, String metadataPrefix) throws Exception {
        String fromDate = from != null ? toJson(from) : null;
        return new ListIdentifiers(baseURL, fromDate, null, null, metadataPrefix);
    }

    private NodeList getHeaders(ListIdentifiers listIdentifiers) {
        Document doc = listIdentifiers.getDocument();
        doc.getDocumentElement().normalize();
        return doc.getElementsByTagName("header");
    }
}
