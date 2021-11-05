<template>
  <a-card :bordered="false">
    <!-- 查询区域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="证书名称">
              <a-input placeholder="请输入证书名称" v-model="queryParam.subject"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="密钥别称">
              <a-input placeholder="请输入密钥别称" v-model="queryParam.privatealias"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查询</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展开' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查询区域-END -->

    <!-- 操作按钮区域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>
      <a-button type="primary" icon="download" @click="handleExportXls('认证证书')">导出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">导入</a-button>
      </a-upload>
      <!-- 高级查询区域 -->
      <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>删除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table区域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已选择 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>项
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无图片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下载
          </a-button>
        </template>

        <span slot="action" slot-scope="text, record">
          <a @click="generate(record)">生成认证</a>

        <!--  <a @click="handleEdit(record)">编辑</a>-->

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleDetail(record)">详情</a>
              </a-menu-item>
              <a-menu-item>
                <a-popconfirm title="确定删除吗?" @confirm="() => handleDelete(record.id)">
                  <a>删除</a>
                </a-popconfirm>
              </a-menu-item>
            </a-menu>
          </a-dropdown>
        </span>

      </a-table>
    </div>

    <sys-license-modal ref="modalForm" @ok="modalFormOk"></sys-license-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import SysLicenseModal from './modules/SysLicenseModal'
  import { httpAction, getAction } from '@/api/manage'
  import { downloadFile } from '@/api/manage'

  export default {
    name: 'SysLicenseList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      SysLicenseModal
    },
    data () {
      return {
        description: '认证证书管理页面',
        // 表头
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'证书名称',
            align:"center",
            dataIndex: 'subject'
          },
          {
            title:'证书生效时间',
            align:"center",
            dataIndex: 'issuedTime',
            customRender:function (text) {
              return !text?"":(text.length>20?text.substr(0,20):text)
            }
          },
          {
            title:'证书失效时间',
            align:"center",
            dataIndex: 'expiryTime',
            customRender:function (text) {
              return !text?"":(text.length>20?text.substr(0,20):text)
            }
          },
          {
            title:'用户类型',
            align:"center",
            dataIndex: 'consumerType'
          },
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          list: "/licensePackage/sysLicense/list",
          delete: "/licensePackage/sysLicense/delete",
          deleteBatch: "/licensePackage/sysLicense/deleteBatch",
          exportXlsUrl: "/licensePackage/sysLicense/exportXls",
          importExcelUrl: "licensePackage/sysLicense/importExcel",
          generateLicense: "/license/generateLicense",
          downloadCertificate: "licensePackage/sysLicense/downloadCertificate",
        },
        dictOptions:{},
        superFieldList:[],
      }
    },
    created() {
    this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      initDictConfig(){
      },
      //认证
      generate(record){
        const that = this;
        this.model = Object.assign({}, record);
        //自定义需要校验的License参数
        let macdate = this.model.macAddress.split(",");
        let ipdate = this.model.ipAddress.split(",");
        let formData= {
          ipAddress: ipdate,
          macAddress: macdate,
          cpuSerial: this.model.cpuSerial,
          mainBoardSerial: this.model.mainBoardSerial,
          oldIpAddress: this.model.oldIpAddress
        };
        this.model.licenseCheckModel = formData;
        let method = 'post';
        let httpurl = this.url.generateLicense;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.result=="ok"){
            that.$message.success("認證成功！")
            //that.$emit('ok');
            this.downCertificate(this.model);
          }else{
            that.$message.warning(res.message);
          }
        })
      },
      //下载认证
      downCertificate(record){
        let name = record.subject+"_license.lic";
        let formData = record;
        downloadFile(this.url.downloadCertificate,name,formData);
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'subject',text:'证书名称',dictCode:''})
        fieldList.push({type:'string',value:'privateAlias',text:'密钥别称',dictCode:''})
        fieldList.push({type:'string',value:'keyPass',text:'密钥密码',dictCode:''})
        fieldList.push({type:'string',value:'storePass',text:'访问秘钥库的密码',dictCode:''})
        fieldList.push({type:'string',value:'licensePath',text:'证书生成路径',dictCode:''})
        fieldList.push({type:'string',value:'privateKeysStorePath',text:'密钥库存储路径',dictCode:''})
        fieldList.push({type:'date',value:'issuedTime',text:'证书生效时间'})
        fieldList.push({type:'date',value:'expiryTime',text:'证书失效时间'})
        fieldList.push({type:'string',value:'consumerType',text:'用户类型',dictCode:''})
        fieldList.push({type:'int',value:'consumerAmount',text:'用户数量',dictCode:''})
        fieldList.push({type:'string',value:'description',text:'描述信息',dictCode:''})
        this.superFieldList = fieldList
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>