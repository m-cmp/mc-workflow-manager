package kr.co.strato.mcmp.oss.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.co.strato.mcmp.oss.model.Oss;

@Mapper
public interface OssMapper {

	List<Oss> selectOssList(@Param("ossCd") String ossCd);
	
	Oss selectOss(@Param("ossId") int ossId);
	Oss selectOssByOssCd(@Param("ossCd") String ossCd);
	
	boolean isOssInfoDuplicated(Oss oss);
	
	int insertOss(Oss oss);
	
	void updateOss(Oss oss);
	
	void deleteOss(@Param("ossId") int ossId);
}
