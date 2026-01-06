global class BooleanStringConverter {

    @InvocableMethod
    global static List<string> replaceTrueFalse(List<String> userNote) {
        
        List<String> returnedNote = new List<String>();
        
        for (String note : userNote){
            note = note.replace('True','Yes');
            note = note.replace('true', 'Yes');
            note = note.replace('False', 'No');
            note = note.replace('false', 'No');
            
            returnedNote.add(note);
        }

        return returnedNote;
        
    }
}