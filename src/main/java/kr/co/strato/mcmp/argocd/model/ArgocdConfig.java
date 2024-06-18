package kr.co.strato.mcmp.argocd.model;

import java.io.Serializable;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ArgocdConfig  implements Serializable {
	
	private static final long serialVersionUID = 6544079550004203269L;
	private String argocdUrl;
	private String argocdUsername;
	private String argocdPassword;
	private String argocdToken;
	
}
