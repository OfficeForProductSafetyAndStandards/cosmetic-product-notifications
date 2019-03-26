package uk.gov.beis.opss.keycloak.providers;

import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber.PhoneNumber;
import org.keycloak.authentication.FormAction;
import org.keycloak.authentication.FormContext;
import org.keycloak.authentication.ValidationContext;
import org.keycloak.events.Details;
import org.keycloak.events.Errors;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.models.utils.FormMessage;
import org.keycloak.services.validation.Validation;

import javax.ws.rs.core.MultivaluedMap;
import java.util.ArrayList;
import java.util.List;

public class RegistrationMobileNumber implements FormAction {

    private static final String MOBILE_NUMBER_FIELD = "mobileNumber";
    private static final String MOBILE_NUMBER_USER_ATTRIBUTE = "mobile_number";

    @Override
    public void buildPage(FormContext context, LoginFormsProvider form) {
    }

    @Override
    public void validate(ValidationContext context) {
        MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
        List<FormMessage> errors = new ArrayList<>();

        context.getEvent().detail(Details.REGISTER_METHOD, "form");
        String eventError = Errors.INVALID_REGISTRATION;

        String mobilePhoneNumber = formData.getFirst(MOBILE_NUMBER_FIELD);
        if (Validation.isBlank(mobilePhoneNumber)) {
            errors.add(new FormMessage(MOBILE_NUMBER_FIELD, "missingMobileNumberMessage"));
        } else if (!isPhoneNumberValid(mobilePhoneNumber)) {
            context.getEvent().detail("mobile_phone_number", mobilePhoneNumber);
            errors.add(new FormMessage(MOBILE_NUMBER_FIELD, "invalidMobileNumberMessage"));
        }

        if (errors.size() > 0) {
            context.error(eventError);
            context.validationError(formData, errors);
        } else {
            context.success();
        }
    }

    private static boolean isPhoneNumberValid(String phoneNumber) {
        String formattedPhoneNumber = convertInternationalPrefix(phoneNumber);

        String region;
        if (isPossibleNationalMobileNumber(formattedPhoneNumber)) {
            region = "GB";
        } else if (isInternationalNumber(formattedPhoneNumber)) {
            region = null;
        } else {
            return false; // If the number cannot be interpreted as an international or possible UK phone number, do not attempt to validate it.
        }

        try {
            PhoneNumber parsedPhoneNumber = PhoneNumberUtil.getInstance().parse(formattedPhoneNumber, region);
            boolean isValidNumber = PhoneNumberUtil.getInstance().isValidNumber(parsedPhoneNumber);
            boolean isFixedLineOrMobile = isFixedLineOrMobile(parsedPhoneNumber);
            return isValidNumber && isFixedLineOrMobile;
        } catch (NumberParseException e) {
            return false;
        }
    }

    private static String convertInternationalPrefix(String phoneNumber) {
        String trimmedPhoneNumber = phoneNumber.trim();
        if (trimmedPhoneNumber.startsWith("00")) {
            return trimmedPhoneNumber.replaceFirst("00", "+");
        }
        return trimmedPhoneNumber;
    }

    private static boolean isPossibleNationalMobileNumber(String phoneNumber) {
        return phoneNumber.trim().startsWith("+44") || phoneNumber.trim().startsWith("07");
    }

    private static boolean isInternationalNumber(String phoneNumber) {
        return phoneNumber.trim().startsWith("+");
    }

    private static boolean isFixedLineOrMobile(PhoneNumber phoneNumber) {
        PhoneNumberUtil.PhoneNumberType phoneNumberType = PhoneNumberUtil.getInstance().getNumberType(phoneNumber);
        boolean isMobile = phoneNumberType == PhoneNumberUtil.PhoneNumberType.MOBILE;
        boolean isFixedLineOrMobile = phoneNumberType == PhoneNumberUtil.PhoneNumberType.FIXED_LINE_OR_MOBILE;
        return isMobile || isFixedLineOrMobile;
    }

    @Override
    public void success(FormContext context) {
        UserModel user = context.getUser();
        MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
        user.setSingleAttribute(MOBILE_NUMBER_USER_ATTRIBUTE, formData.getFirst(MOBILE_NUMBER_FIELD));
    }

    @Override
    public boolean requiresUser() {
        return false;
    }

    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        return true;
    }

    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
    }

    @Override
    public void close() {
    }
}
