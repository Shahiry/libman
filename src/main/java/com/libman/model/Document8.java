package com.libman.model;

public class Document8 {
    private int id, publicYear, quantity, borrowDuration;
    private String coverPicture, name, type, author, publicHouse, description;

    public int getId() { return id; }                       public void setId(int id) { this.id = id; }
    public String getCoverPicture() { return coverPicture; } public void setCoverPicture(String v) { coverPicture = v; }
    public String getName() { return name; }                public void setName(String v) { name = v; }
    public String getType() { return type; }                public void setType(String v) { type = v; }
    public String getAuthor() { return author; }            public void setAuthor(String v) { author = v; }
    public int getPublicYear() { return publicYear; }       public void setPublicYear(int v) { publicYear = v; }
    public String getPublicHouse() { return publicHouse; }  public void setPublicHouse(String v) { publicHouse = v; }
    public String getDescription() { return description; }  public void setDescription(String v) { description = v; }
    public int getQuantity() { return quantity; }           public void setQuantity(int v) { quantity = v; }
    public int getBorrowDuration() { return borrowDuration; } public void setBorrowDuration(int v) { borrowDuration = v; }
}
